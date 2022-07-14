// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "./BinaryTreeNode.sol";

contract BinaryTree{
    event AddNewNode(bytes32 parent, uint value);

    uint private count;
    mapping(bytes32 => BinaryTreeNode.Node) public nodes;
    bytes32 public head;

    bytes32 private NULL = 0x00;
    uint[] arrayTraversals;
    string typeTraversals;

    function add(uint value) public{
        BinaryTreeNode.Node memory node = BinaryTreeNode.Node(value, NULL, NULL);
        bytes32 id = keccak256(abi.encodePacked(node.value, blockhash(block.number)));
        nodes[id] = node;
        
        if(head == NULL)
            head = id;
        else
            addTo(head, id);
        count++;
    }

    function addTo(bytes32 parent, bytes32 id) private{
        if(int(nodes[id].value) - int(nodes[parent].value) < 0){
            if(nodes[parent].left == NULL)
                nodes[parent].left = id;
            else    
                addTo(nodes[parent].left, id);
        }
        else{
            if(nodes[parent].right == NULL)
                nodes[parent].right = id;
            else
                addTo(nodes[parent].right, id);    
        }
    }

    function getAmount() public view returns(uint){
        return count;
    }

    function getHead() public view returns(uint){
        return nodes[head].value;
    }

    function contains(uint value) public view returns(bool){
        bytes32 current;
        bytes32 parent;
        (current, parent) = findWithParent(value);
        return current != NULL;
    }
    // Search value in binary tree
    function findWithParent(uint value) private view returns(bytes32 current, bytes32 parent){
        int result;
        current = head;
        parent = NULL;

        while(current != NULL){
            result = compareTo(current, value);
            if(result > 0){
                parent = current;
                current = nodes[current].left;
            }
            else if(result < 0){
                parent = current;
                current = nodes[current].right;
            }
            else
                break;
        }
    }

    function compareTo(bytes32 node, uint value) private view returns(int){
        return int(nodes[node].value) - int(value);
    }

    function getTraversal() public view returns(uint[] memory array, string memory typeTreversal){
        array = arrayTraversals;
        typeTreversal = typeTraversals;
        return (array, typeTreversal);
    }

    function traversal(string memory typeTraversal) public{
        delete arrayTraversals;

        if(keccak256(abi.encodePacked(typeTraversal)) == keccak256("inOrderTraversal"))
            inOrderTraversal(head);
        else if(keccak256(abi.encodePacked(typeTraversal)) == keccak256("preOrderTraversal"))
            preOrderTraversal(head);
        else
            postOrderTraversal(head);
    }

    function inOrderTraversal(bytes32 id) private{
        if(nodes[id].left != NULL)
            inOrderTraversal(nodes[id].left);

        arrayTraversals.push(nodes[id].value);

        if(nodes[id].right != NULL)
            inOrderTraversal(nodes[id].right);
    }

    function postOrderTraversal(bytes32 id) private{
        if(nodes[id].left != NULL)
            postOrderTraversal(nodes[id].left);

        if(nodes[id].right != NULL)
            postOrderTraversal(nodes[id].right);

        arrayTraversals.push(nodes[id].value);
    }

    function preOrderTraversal(bytes32 id) private{
        arrayTraversals.push(nodes[id].value);

        if(nodes[id].left != NULL)
            preOrderTraversal(nodes[id].left);

        if(nodes[id].right != NULL)
            preOrderTraversal(nodes[id].right);
    }

    function remove(uint value) public returns(bool){
        bytes32 current;
        bytes32 parent;
        
        (current, parent) = findWithParent(value);

        if(current == NULL)
            return false;

        count--;

        // Delete node, not have right descendant
        if(nodes[current].right == NULL){
            // Remove node parent
            if(parent == NULL)
                head = nodes[current].left;
            else{
                int result = compareTo(parent, nodes[current].value);
                if(result > 0)
                    nodes[parent].left = nodes[current].left;
                else if(result < 0)
                    nodes[parent].right = nodes[current].left;
            }
        }
        // The node to be removed has a right child and the child has no left node
        else if(nodes[nodes[current].right].left == NULL){
            nodes[nodes[current].right].left = nodes[current].left;
            if(parent == NULL)
                head = nodes[current].right;
            else{
                int result = compareTo(parent, nodes[current].value);
                if(result > 0)
                    nodes[parent].left = nodes[current].right;
                else if(result < 0)
                    nodes[parent].right = nodes[current].right;
            }
        }
        // The node to be removed has a right child and the child has a right node
        else{
            bytes32 leftmost = nodes[nodes[current].right].left;
            bytes32 leftmostParent = nodes[current].right;

            while(nodes[leftmost].left != NULL){
                leftmostParent = leftmost;
                leftmost = nodes[leftmost].left;
            }

            nodes[leftmostParent].left = nodes[leftmost].right;

            nodes[leftmost].left = nodes[current].left;
            nodes[leftmost].right = nodes[current].right;

            if(parent == NULL)
                head = leftmost;
            else{
                int result = compareTo(parent, nodes[current].value);

                if(result > 0)
                    nodes[parent].left = leftmost;
                else if(result < 0)
                    nodes[parent].right = leftmost;
            }
        }
        return true;
    }
}