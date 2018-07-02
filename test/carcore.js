var carcore = artifacts.require("./carCore.sol");

contract('CarCore', function(accounts) {

    account0 = accounts[0];
    account1 = accounts[1];
    account2 = accounts[2];

    it("should be owner of car", function() {
        return carcore.deployed().then(function(instance) {
            return instance.amOwner.call({from: account0});
        });
    });

    it("shouldn't be owner of car", function() {
        return carcore.deployed().then(function(instance) {
            return (instance.amOwner.call({from: account1}) == false);
        });
    });

    it("shouldn't start engine", function() {
        return carcore.deployed().then(function(instance) {
            return (instance.startEngine.call({from: accounts[0]}) == false);
        });
    });

    it("should administer authority", function() {
        return carcore.deployed().then(function(instance) {
            core = instance;
            return core.newAuthority.call(
                account1, 'TÜV', 1, {from: account0}
            );
        }).then(function(amauthority) {
            return core.amAuthority({from: account1});
        });
    });

    // @dev needs to be rewritten as async
    /*it("should apply new permit", function() {
        return carcore.deployed().then(function(instance) {
            core = instance;
            return core.newAuthority.call(
                account1, 'TÜV', 1, {from: account0}
            );
        }).then(function(amauthority) {
            return core.amAuthority({from: account1});
        }).then(function(newpermit) {
            return core.newPermit.call(
                4070908800, 0, {from: account1}
            );
        });
    });*/
});
