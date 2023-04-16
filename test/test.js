const {
    expectEvent, // Assertions for emitted events
    expectRevert,
    time
} = require("@openzeppelin/test-helpers");
const { italic } = require("ansi-colors");
const { use, Assertion } = require("chai");
var chai = require("chai");

const { on } = require("events");
var expect = chai.expect;

const TheUnexploredSpaceOfKalpanaChawla = artifacts.require('TheUnexploredSpaceOfKalpanaChawla')
const Operator = artifacts.require('Operator')
contract(`TheUnexploredSpaceOfKalpanaChawla`,async(accounts)=>{
        var erc1155Instance;
        var operatorInstance;
        var name = "kalpana"
        var symbol = "kalapana"
        var baseURI = "sample"
        before(async()=>{
            operatorInstance = await Operator.new();
            erc1155Instance = await TheUnexploredSpaceOfKalpanaChawla.new(name,symbol,baseURI,operatorInstance.address)
        })
    describe(`Contract Deployment`,async()=>{
        it(`Contract Deployment address`,async()=>{
            console.log(`Contract address`,erc1155Instance.address);
            console.log(`operator address`,operatorInstance.address);
        })
    })
    describe(`Mint Function`,async()=>{
        it(`Mint Functionality`,async()=>{
            let tokenUri = 'sample';
            let supply = 1;
            let CelebrityAdmin  = accounts[1];
            await operatorInstance.addCelebrityAdmin(CelebrityAdmin,{from:accounts[0]})
            let minter = accounts[2];
            await operatorInstance.addMinter(minter,{from:CelebrityAdmin})
            let creator = accounts[1]
            await operatorInstance.mint1155(erc1155Instance.address,creator,tokenUri,supply,{from:minter})
        })
        it(`safeTransfer1155`,async()=>{
            let minter = accounts[2];
            let receiver = accounts[4]
            let creator = accounts[1]
            const tokenid = 1
            await operatorInstance.safeTransfer1155(erc1155Instance.address,creator,tokenid,receiver,1,{from:minter})
        }) 
        it(`setRoyaltyFee`,async()=>{
            let receiver = accounts[4]
            let royaltyFee = 4
            let CelebrityAdmin  = accounts[1];
            await operatorInstance.setRoyaltyFee(erc1155Instance.address,receiver,royaltyFee,{from:CelebrityAdmin})
        })
        it(`changeUriEditor`,async()=>{
            const newEditor = accounts[1];
            await erc1155Instance.changeUriEditor(newEditor,{from:accounts[0]})
        })
        it(`updateTokenURI`,async()=>{
            var tokenid = "1"
            var string = 'hello'
            const editor = accounts[1];
            let tokenUri = 'sample';
            let olduri = await erc1155Instance.uri(tokenid)
            console.log(olduri);
            let event = await erc1155Instance.updateTokenURI(tokenid,string,{from:editor})
            // console.log(event);
            let uri = await erc1155Instance.uri(tokenid)
            console.log(uri);

        })

    })
})
