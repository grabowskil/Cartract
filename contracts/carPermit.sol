pragma solidity ^0.4.22;

import { CarAccessControl } from "./carAccessControl.sol";

contract CarPermit is CarAccessControl {

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

    // @dev standard restrictions are constructed.
    constructor() public {
        _restrictions[0] = uint256(0);  // empty inspection token added
        _restrictions[1] = uint256(0);  // empty insurance token added
    }

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

    /* INTERNAL INTERFACES */

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
        return newPermitId;
    }

    /* HELPER FUNCTIONS */
    // @dev private function checks if permit is already valid
    function isValid(uint64 _validFrom) private view returns(bool) {
        return (_validFrom <= uint64(now));
    }

    // @dev private function checks if permit is still valid
    function isStillValid(uint64 _validTill) private view returns(bool) {
        return (_validTill > uint64(now));
    }

    // @notice checks validity of a parsed permit
    // @dev private functions, accepts output from getPermit as input
    function isValidPermit(
        uint256 _issuingAuthorityId,
        uint64 _validFrom,
        uint64 _validTill
    )
        private
        view
        returns(bool) {
            return (
                isStillAuthority(_issuingAuthorityId)
                && isStillValid(_validTill)
                && isValid(_validFrom)
            );
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
        return newPermitId;
    }

    function updatePermits() internal {
        for (uint256 i = 0; i < _permits.length - 1; ++i) {
            (uint256 a, uint64 b, uint64 c, uint8 d) = getPermit(i);
            if (check == false && isValidPermit(a, b, c, d)) {
                _restrictions[_permitType] = i;
            }
        }
    }

    // @notice interface to check if a valid permit for parsed type exists
    // @dev tries to get the standard permit from "_restrictions" first before
    //  iterating through "_permits". If the standard permit is invalid but
    //  another valid permit can be found, the standard permit is updated.
    function isPermitted(uint8 _permitType) internal returns(bool) {
        (uint256 a, uint64 b, uint64 c, uint8 d) = getPermit(_restrictions[_permitType]);
        if (isValidPermit(a, b, c, d)) {
            return true;
        } else {
            return false;
        }
    }
}
