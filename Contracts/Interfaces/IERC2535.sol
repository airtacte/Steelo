// SPDX-License-Identifier: MIT
// contracts/DiamondCutFacet.sol
pragma solidity ^0.8.19;

interface IERC2535 {
    enum FacetCutAction {Add, Replace, Remove}
    // Add=0, Replace=1, Remove=2

    struct FacetCut {
        address facetAddress;
        FacetCutAction action;
        bytes4[] functionSelectors;
    }

    event DiamondCut(FacetCut[] _diamondCut, address _init, bytes _calldata);

    // Returns the URI for the metadata of the contract
    function contractURI() external view returns (string memory);

    // Returns the URI for the metadata of a token
    function tokenURI(uint256 _tokenId) external view returns (string memory);

    // Checks whether a certain function is supported by the contract
    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    // Adds or replaces a function signature hash in the mapping
    function addInterfaceSig(bytes4 sig, bytes32 hash) external;

    // Removes a function signature hash from the mapping
    function removeInterfaceSig(bytes4 sig) external;
}