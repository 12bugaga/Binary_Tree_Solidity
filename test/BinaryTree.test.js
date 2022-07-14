const { expect } = require("chai");
const { BigNumber } = require("ethers");
const { ethers } = require("hardhat");

describe("SortAlgorithms", function() {
    let tree;
    let array = [8,5,12,3,7,10,15];
    let arrayInOrderTraversal = [3,5,7,8,10,12,15];
    let arrayPostOrderTraversal = [3,7,5,10,15,12,8];
    let arrayPreOrderTraversal = [8,5,3,7,12,10,15];
    let arrayPreOrderAfterRemoveValues = [8,7,3,12];
    beforeEach(async function() {

        acc1 = await ethers.getSigners();
        const Tree = await ethers.getContractFactory("BinaryTree", acc1);
        tree = await Tree.deploy();
        await tree.deployed();

        for(let i = 0; i < array.length; i++){
            await tree.add(array[i]);
        }
    })

    it("Add values and check amount " + array.length, async function(){
        expect(array.length).to.eq(await tree.getAmount());
    })

    it("Binary tree must have contain 7 and not contain 100",
    async function(){
        expect(true).to.eq(await tree.contains(7));
        expect(true).to.eq(await tree.contains(8));
        expect(false).to.eq(await tree.contains(100));
        expect(false).to.eq(await tree.contains(0));
    })

    it("Test inOrderTraversal should be " + arrayInOrderTraversal, async function(){
        await tree.traversal("inOrderTraversal");
        let result = await tree.getTraversal();
        for(let i =0; i < arrayInOrderTraversal; i++)
            expect(arrayInOrderTraversal[i]).to.eq(result.array[i]);
    })

    it("Test postOrderTraversal should be " + arrayPostOrderTraversal, async function(){
        await tree.traversal("postOrderTraversal");
        let result = await tree.getTraversal();
        for(let i =0; i < arrayPostOrderTraversal; i++)
            expect(arrayPostOrderTraversal[i]).to.eq(result.array[i]);
    })

    it("Test preOrderTraversal should be " + arrayPreOrderTraversal, async function(){
        await tree.traversal("preOrderTraversal");
        let result = await tree.getTraversal();
        for(let i =0; i < arrayPreOrderTraversal; i++)
            expect(arrayPreOrderTraversal[i]).to.eq(result.array[i]);
    })

    it("Remove 15 and 5", async function(){
        await tree.traversal("preOrderTraversal");
        let result = await tree.getTraversal();
        for(let i = 0; i < arrayPreOrderTraversal; i++)
            expect(arrayPreOrderTraversal[i]).to.eq(result.array[i]);

        await tree.remove(15);
        await tree.remove(5);
        await tree.traversal("preOrderTraversal");
        result = await tree.getTraversal();
        for(let i = 0; i < arrayPreOrderAfterRemoveValues.length; i++)
            expect(arrayPreOrderAfterRemoveValues[i]).to.eq(result.array[i]);
    })
})