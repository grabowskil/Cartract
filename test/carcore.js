var CarCore = artifacts.require("./carCore.sol");

contract('CarCore', function(accounts) {
    var car;
    var account0 = accounts[0];
    var account1 = accounts[1];
    var account2 = accounts[2];

    beforeEach("setup contract for each test", async function() {
        car = await CarCore.new(account0);
    });

    it("should be only owner of car", async function() {
        assert.equal(
            await car.amOwner({from: account0})
            && await car.amOwner({from: account1}) == false,
            true);
    });

    it("shouldn't start engine", async function() {
        assert.equal(await car.startEngine({from: account0}), false);
    });

    it("should administer authority", async function() {
        await car.newAuthority(account1, "TÜV", 1, {from: account0});
        assert.equal(await car.amAuthority({from: account1}), true);
    });

    it("should apply new permits and start engine", async function() {
        await car.newAuthority(account1, "TÜV", 1, {from: account0});
        await car.newPermit(4070908800, 0, {from: account1});
        await car.newAuthority(account2, "Versicherung", 2, {from: account0});
        await car.newPermit(4070908800, 1, {from: account2});
        assert.equal(await car.startEngine({from: account0}), true);
    });

    it("should remove authority", async function() {
        await car.newAuthority(account1, "Test", 4, {from: account0});
        wasCreated = await car.amAuthority({from: account1});
        await car.removeAuthority(await car.getIndexAuthority(account1), {from: account0});
        wasRemoved = (await car.amAuthority({from: account1}) == false);
        assert.equal(wasRemoved && wasCreated, true);
    });

    it("should transfer owner", async function() {
        wasNotOwner = (await car.amOwner({from: account1}) == false);
        await car.transferOwner(account1, {from: account0});
        assert.equal(await car.amOwner({from: account1}) && wasNotOwner, true)
    })
});
