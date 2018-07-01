pragma solidity ^0.4.22;

/// @title core contract to launch and interact with cars
/// @author Lennart Grabowski

import { CarPermit } from "./carPermit.sol";

contract CarCore is CarPermit {

    // @notice central function to start the car's engine
    // @dev this function verifies if a valid inspection (id: 0)
    //  and insurance (id: 1) is available then starts the engine.
    //  Only owner can interact with it.
    function startEngine() constant public onlyOwner returns(bool) {
        return (isPermitted(uint8(0)) && isPermitted(uint8(1)));
    }

    function changedPermits() public onlyAuthorities {
        updatePermits(0);
        updatePermits(1);
    }
}
