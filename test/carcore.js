var carcore = artifacts.require("./carCore.sol");

contract('CarCore', function(accounts) {
    it("should be owner of car", function() {
        return carcore.deployed().then(function(instance) {
            return instance.amOwner.call({from: accounts[0]});
        });
    });

    it("should administer authority", function() {
        return carcore.deployed().then(function(instance) {
            return instance.newAuthority.call(
                accounts[1],
                'TÜV',
                1,
                {from: accounts[0]}
            );
        });
    });

    it("should apply new permit", function() {

        return carcore.deployed().then(function(instance) {
            car = instance;
            return car.newAuthority.call(
                accounts[1],
                'TÜV',
                1,
                {from: accounts[0]}
            );
        }).then(function(permit) {
            return car.newPermit.call(
                4070908800,
                0,
                {from: accounts[1]}
            );
        }).then(function(permit) {
            return car.getPermit.call(0, {from: accounts[0]});
        });
    });
});
