// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 Steelo Labs Ltd
pragma solidity ^0.8.10;

contract SIPTemplate {
    enum ProposalType {
        ChangeRates,
        AddFacet,
        AmendFunction
    }

    struct Proposal {
        ProposalType proposalType;
        address facetAddress;
        bytes4 functionSelector;
        bytes data;
    }

    function proposeChangeRates(
        address _facet,
        bytes4 _function,
        uint256 _newRate
    ) public pure returns (Proposal memory) {
        bytes memory data = abi.encode(_function, _newRate);
        return Proposal(ProposalType.ChangeRates, _facet, _function, data);
    }

    function proposeAddFacet(
        address _facet,
        bytes4 _function,
        bytes memory _data
    ) public pure returns (Proposal memory) {
        return Proposal(ProposalType.AddFacet, _facet, _function, _data);
    }

    function proposeAmendFunction(
        address _facet,
        bytes4 _function,
        bytes memory _data
    ) public pure returns (Proposal memory) {
        return Proposal(ProposalType.AmendFunction, _facet, _function, _data);
    }
}
