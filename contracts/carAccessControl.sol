pragma solidity ^0.4.22;

/// @title facet of CarCore to control access to a car's functions
/// @author Lennart Grabowski

import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';

contract CarAccessControl is Ownable {

    event AuthorityAdded(uint256 authorityId, address authority, bytes32 name, uint8 level);
    event AuthorityRemoved(uint256 authorityId);

    // @dev the main authority struct. Every authority needs to be identified by
    //  address and some identifying name and type. Additonally an
    //  authority-level must be given to the authority's relevance. Levels are
    //  unsigned 8-bit integers, smaller levels are more relevant/"powerful".
    struct Authority {
        address authority;  //authority's address
        bytes32 name;       //identifying name
        uint8 level;        //authority-level
    }

    // @dev An array containing all identified authorities.
    Authority[] private _authorities;

    // @dev for cheap checks if an address is part of authorities these Mappings
    //  need to be maintained additionally to "_authorities".
    mapping (address => bool) private _inAuthorities;
    mapping (address => uint256) private _indexInAuthorities;

    // @notice returns the authority's address, name and level associated with
    //  parsed id
    function getAuthority(
        uint256 _authorityId
    )
        constant
        public
        returns(address, bytes32, uint8)
    {
        if (_authorityId < _authorities.length && _authorityId >= 0) {
            return (
                _authorities[_authorityId].authority,
                _authorities[_authorityId].name,
                _authorities[_authorityId].level
            );
        }
    }

    // @notice returns the authority's index in "_authorities"
    function getIndexAuthority(
        address _authority
    )
        constant
        public
        returns(uint256)
    {
        return _indexInAuthorities[_authority];
    }

    /* INTERNAL INTERFACE */
    // @notice private function to add new authority
    // @dev never make public as no access control happens
    function addAuthority(
        address _newAuthority,
        bytes32 _name,
        uint8 _level
    )
        private
        returns(uint256)
    {
        require(_inAuthorities[_newAuthority] == false);

        Authority memory _authority = Authority({
            authority: _newAuthority,
            name: _name,
            level: _level
        });
        uint256 newAuthorityId = _authorities.push(_authority) - 1;
        _inAuthorities[_newAuthority] = true;
        _indexInAuthorities[_newAuthority] = newAuthorityId;

        emit AuthorityAdded(newAuthorityId, _newAuthority, _name, _level);

        return newAuthorityId;
    }

    // @notice private function to delete authority
    // @dev never make public as no access control happens
    function deleteAuthority(address _authority) private {
        delete _authorities[_indexInAuthorities[_authority]];
        _inAuthorities[_authority] = false;

        emit AuthorityRemoved(_indexInAuthorities[_authority]);
        _indexInAuthorities[_authority] = 0;
    }

    /* ACCESS MODIFIERS */
    modifier onlyAuthorities() {
        require(_inAuthorities[msg.sender]);
        _;
    }

    modifier onlyAuthoritiesLevel(uint8 _desiredLevel) {
        (address a, bytes32 b, uint8 c) =
            getAuthority(
                getIndexAuthority(msg.sender)
            );
        require(
            _inAuthorities[msg.sender]
            && c <= uint8(_desiredLevel)
        );
        _;
    }

    /* EXTERNAL INTERFACES */
    // @notice interface to transfer ownership
    function transferOwner(
        address _newOwner
    )
        public
        onlyAuthoritiesLevel(uint8(3))
    {
        _transferOwnership(_newOwner);
        addAuthority(_newOwner, 'owner', uint8(3));
    }

    // @notice interface to add new authority
    function newAuthority(
        address _newAuthority,
        bytes32 _name,
        uint8 _level
    )
        public
        onlyAuthorities
        returns(uint256)
    {
        return addAuthority(_newAuthority, _name, _level);
    }

    // @notice interface to remove authority
    // @dev only athorities with a lower level can remove other authorities
    function removeAuthority(
        uint256 _authorityId
    )
        public
        onlyAuthorities
        returns(bool)
    {
        (address a, bytes32 b, uint8 c) = getAuthority(_authorityId);
        (address x, bytes32 y, uint8 z) =
            getAuthority(
                getIndexAuthority(msg.sender)
            );
        // authority-level of sender needs to be lower to remove another
        //  authority. Sender can remove itself, unless it is owner.
        if (c > z || (a == x && a != owner)) {
            deleteAuthority(a);
            return true;
        } else {
            return false;
        }
    }

    /* HELPER FUNCTIONS */
    // @dev check my own ownership status
    function amOwner() public view returns(bool) {
        return (msg.sender == owner);
    }

    // @dev check my own authority status
    function amAuthority() public view returns(bool) {
        return _inAuthorities[msg.sender];
    }

    // @dev can be used to check if _authorityId is in Authority
    function isStillAuthority(uint256 _authorityId) internal view returns(bool) {
        (address a, bytes32 b, uint8 c) = getAuthority(_authorityId);
        return _inAuthorities[a];
    }

    /* CONSTRUCTION */
    constructor() public {
        addAuthority(owner, 'owner', uint8(3)); // owner gets level 3 authority
    }
}
