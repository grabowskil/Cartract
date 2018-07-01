pragma solidity ^0.4.22;

import { CarAccessControl } from "./carAccessControl.sol";

contract CarPermit is CarAccessControl {

    event PermitAdded(uint256 permitId, uint64 validTill, uint8 permitType);
    // event PermitStatus(bool isStillAuthority, bool isValid, bool isStillValid, bool permitType);

    // @dev the main permit struct. Every permit needs to have an issuing
    //  authority represented by the ID of the authority in the "_authorities"
    //  array. Additionally a validity period must be given as start and end
    //  date. The permittype defines the kind of permit:
    //      0 = inspection
    //      1 = insurance
    struct Permit {
        uint256 issuingAuthority;
        uint64 validFrom;
        uint64 validTill;
        uint8 permitType;
    }

    // @dev An array containing all issued permits.
    Permit[] private _permits;

    // @dev for cheap checks of the standard permit the corresponding
    //  restrictions are mapped.
    mapping (uint8 => uint256) private _restrictions;

    // @notice returns permit's authority, validity period and type associated
    //  with parsed id
    function getPermit(
        uint256 _permitId
    )
        constant
        public
        returns (
            uint256, uint64, uint64, uint8
        )
    {
        if (_permitId <= _permits.length - 1 && _permitId >= 0) {
            uint256 _issuingAuthorityId = _permits[_permitId].issuingAuthority;
            uint64 _validFrom = _permits[_permitId].validFrom;
            uint64 _validTill = _permits[_permitId].validTill;
            uint8 _permitType = _permits[_permitId].permitType;
            return (_issuingAuthorityId, _validFrom, _validTill, _permitType);
        } else {
            // @notice instead of failing if requested ID is out-of-bounds
            //  returns authority-id -1 (unsigned), validity period epoch and
            //  highest possible type
            return (uint256(-1), uint64(0), uint64(0), uint8(255));
        }
    }

    // @notice private funtion to add new permit
    // @dev never make public as no access control happens
    function addPermit(
        uint64 _validTill,
        uint8 _permitType
    )
        private
        returns(uint256)
    {
        Permit memory _permit = Permit({
            issuingAuthority: getIndexAuthority(msg.sender),
            validFrom: uint64(now),
            validTill: _validTill,
            permitType: _permitType
        });
        uint256 newPermitId = _permits.push(_permit) - 1;
        _restrictions[_permitType] = newPermitId;

        emit PermitAdded(newPermitId, _validTill, _permitType);

        return newPermitId;
    }

    // @dev standard restrictions are constructed.
    constructor() public {
        addPermit(uint64(0), uint8(255));   // dummy permit added
        _restrictions[0] = uint256(-1);     // dummy inspection token added
        _restrictions[1] = uint256(-1);     // dummy insurance token added
    }

    /* HELPER FUNCTIONS */
    // @notice checks validity of a parsed permit
    // @dev private functions, accepts output from getPermit as input
    function isValidPermit(
        uint256 _issuingAuthorityId,
        uint64 _validFrom,
        uint64 _validTill,
        uint8 _permitType,
        uint8 _requiredPermitType
    )
        private
        view
        returns(bool)
    {
        // @dev Helpful for debugging, but expensive to use, so don't.
        /*
        emit PermitStatus(
            isStillAuthority(_issuingAuthorityId),
            bool (_validTill > uint64(now)),
            bool (_validFrom <= uint64(now)),
            bool (_permitType == _requiredPermitType)
        );*/

        return (
            isStillAuthority(_issuingAuthorityId)
            && (_validTill > uint64(now))
            && (_validFrom <= uint64(now))
            && (_permitType == _requiredPermitType)
        );
    }

    /* INTERNAL INTERFACES */
    // @notice interface to update "_restrictions"
    function updatePermits(uint8 _requiredPermitType) internal {
        for (uint256 i = 0; i < _permits.length; ++i) {
            (uint256 a, uint64 b, uint64 c, uint8 d) = getPermit(i);
            if (isValidPermit(a, b, c, d, _requiredPermitType)) {
                _restrictions[_requiredPermitType] = i;
            }
        }
    }

    // @notice interface to check if a valid permit for parsed type exists
    // @dev tries to get the standard permit from "_restrictions" first before
    //  iterating through "_permits". If the standard permit is invalid but
    //  another valid permit can be found, the standard permit is updated.
    function isPermitted(uint8 _requiredPermitType) internal returns(bool) {
        (uint256 a, uint64 b, uint64 c, uint8 d) = getPermit(_restrictions[_requiredPermitType]);
        if (isValidPermit(a, b, c, d, _requiredPermitType)) {
            return true;
        } else {
            return false;
        }
    }

    /* EXTERNAL INTERFACES */
    // @notice interface to add new permit
    // @dev only authorities level 2 and lower can interact
    function newPermit(
        uint64 _validTill,
        uint8 _permitType
    )
        public
        onlyAuthoritiesLevel(uint8(2))
        returns(uint256)
    {
        uint256 newPermitId = addPermit(_validTill, _permitType);
        updatePermits(_permitType);
        return newPermitId;
    }
}
