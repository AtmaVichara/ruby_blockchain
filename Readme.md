# Blockchain in Ruby

## Little Intro into the What and Why?
* WHAT: This is a simple implementation of a barebones blockchain and cryptocurrency in ruby.
* WHY: The main reason for building this was for learning purposes to understand how a blockchain works, and by extension how cryptocurrencies are made from a blockchain.

## Current State (updated: Sunday, January 21, 2018, 18:36:50)
* Currently this is a barebones blockchain... Or at least the most simple case of one. While it can technically be called a blockchain in it's current form, in reality it is just a linked list with hashes, that also verifies the hashes for proof of work. To be more in line with a blockchain, implementing a merkle tree is the next step.
* Currently working on merkle tree algorithm. At the moment, the MerkleTree class is grabbing each_slice(2) of an array of ids, that will later on be represented as the clients transactions and pub_key (still have to figure out which), and hashing each, then shoveling that into an instance variable called hashes. Next step is to add in edge case for odd number of clients, implement recursion to keep hashing until there is only one hash, and somehow store those previous hashes in to nodes, with the original id hashes as the leaf nodes... A lot of work, but should be simple after a bit more research and toying around. All current work is on merkle_branch.

## Future Plans
* The future goal for this little project is to flesh out a fully fleshed out blockchain app.
* At the moment, the current issues are further implementations that have yet to be added. More research and study must be conducted before I am able to do so.

#### Sources
* Main learning resource: https://github.com/Haseeb-Qureshi/lets-build-a-blockchain
* Merkle learning resource: https://blog.ethereum.org/2015/11/15/merkling-in-ethereum/
