pragma solidity ^0.4.22;

import { CarAccessControl } from "./carAccessControl.sol";

contract CarPermit is CarAccessControl {

    struct Permit {
        uint256 issuingAuthority;
        uint64 validFrom;
        uint64 validTill;
        uint8 permitType;
    }

    Permit[] private _permits;

    mapping (uint8 => uint256) private _restrictions;

    constructor() public {
        _restrictions[0] = uint256(0);  // empty inspection token added
        _restrictions[1] = uint256(0);  // empty insurance token added
    }

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
            return (uint256(-1), uint64(0), uint64(0), uint8(255));
        }
    }

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

    function isValid(uint64 _validFrom) private view returns(bool) {
        return (_validFrom <= uint64(now));
    }

    function isStillValid(uint64 _validTill) private view returns(bool) {
        return (_validTill > uint64(now));
    }

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

    function isPermitted(uint8 _permitType) internal returns(bool) {
        (uint256 a, uint64 b, uint64 c, uint8 d) = getPermit(_restrictions[_permitType]);
        if (isValidPermit(a, b, c)) {
            return true;
        } else {
            bool check = false;
            for (uint256 i = 0; i < _permits.length - 1; ++i) {
                (a, b, c, d) = getPermit(i);
                if (check == false && isValidPermit(a, b, c)) {
                    _restrictions[_permitType] = i;
                    check = true;
                }
            }
            return check;
        }
    }
}
