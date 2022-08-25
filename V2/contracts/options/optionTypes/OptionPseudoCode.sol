// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.4;

// Base / minimal Option Class not used in order keep pseudo-code concise:
// import "./OptionBaseMinimal.sol";
import "../../../utils/ContractKeys.sol";

contract Option {
    // bytes32 public constant LOAN_TYPE = bytes32("DIRECT_LOAN_FIXED_OFFER");
    bytes32 public constant OPTION_TYPE = bytes32("VANILLA_OPTION");

    // constructor(
    //     address _admin,
    //     address _nftfiHub,
    //     bytes32 _loanCoordinatorKey,
    //     address[] memory _permittedErc20s
    // ) BaseLoan(_admin) {
    //     ...
    // }
    constructor(
        address _admin,
        address _nftfiHub,
        address[] memory _permittedErc20s
    ) BaseOption(_admin) {
        hub = INftfiHub(_nftfiHub);
        // LOAN_COORDINATOR = ContractKeys.getIdFromStringKey("LOAN_COORDINATOR");
        // A new NFTfi coordinator specifically for Options should be created
        // to keep Option IDs independent of Loans
        OPTION_COORDINATOR = ContractKeys.getIdFromStringKey("OPTION_COORDINATOR");
        for (uint256 i = 0; i < _permittedErc20s.length; i++) {
            _setERC20Permit(_permittedErc20s[i], true);
        }
    }

    // function acceptOffer(
    //     Offer memory _offer,
    //     Signature memory _signature,
    //     BorrowerSettings memory _borrowerSettings
    // ) external whenNotPaused nonReentrant {
    //     ...
    // }
    function fillOrder(
        Order memory _order,
        Signature memory _signature,
        MakerSettings memory _makerSettings
    ) external whenNotPaused nonReentrant {
        address nftWrapper = _getWrapper(_order.nftCollateralContract);
        _optionSanityChecks(_order, nftWrapper);
        _optionSanityChecksOrder(_order);
        _acceptOffer(
            OPTION_TYPE,
            _setupOptionTerms(_order, nftWrapper),
            _setupOptionExtras(_makerSettings.revenueSharePartner, _makerSettings.referralFeeInBasisPoints),
            _order,
            _signature
        );
    }

    // function _acceptOffer(
    //     bytes32 _loanType,
    //     LoanTerms memory _loanTerms,
    //     LoanExtras memory _loanExtras,
    //     Offer memory _offer,
    //     Signature memory _signature
    // ) internal {
    //     ...
    // }
    function _fillOrder(
        bytes32 _optionType,
        OptionTerms memory _optionTerms,
        OptionExtras memory _optionExtras,
        Offer memory _offer,
        Signature memory _signature
    ) internal {
        // Misc. checks and balances
        require(!_nonceHasBeenUsedForUser[_signature.signer][_signature.nonce], "Taker nonce invalid");
        _nonceHasBeenUsedForUser[_signature.signer][_signature.nonce] = true;
        require(NFTfiSigningUtils.isValidLenderSignature(_offer, _signature), "Taker signature is invalid");

        // Create Option and get Option ID
        optionId = _createOption(_optionType, _optionTerms, _optionExtras, msg.sender, _signature.signer, _offer.referrer);

        // Emit an event with all relevant details from this transaction.
        emit OptionOrderFilled(optionId, msg.sender, _signature.signer, _optionTerms, _optionExtras)
    }

    // function _createLoan(
    //     bytes32 _loanType,
    //     LoanTerms memory _loanTerms,
    //     LoanExtras memory _loanExtras,
    //     address _borrower,
    //     address _lender,
    //     address _referrer
    // ) internal returns (uint32) {
    //     ...
    // }
    function _createOption(
        bytes32 _loanType,
        LoanTerms memory _loanTerms,
        LoanExtras memory _loanExtras,
        address _borrower,
        address _lender,
        address _referrer
    ) internal returns (uint32) {
        // TODO
        // _transferNFT(_loanTerms, _borrower, address(this));
        
        return _createLoanNoNftTransfer(_loanType, _loanTerms, _loanExtras, _borrower, _lender, _referrer);
    }

    // function _payoffAndFee(LoanTerms memory _loanTerms)
    //     internal
    //     pure
    //     override
    //     returns (uint256 adminFee, uint256 payoffAmount)
    // {
    //     ...
    // }
    function _payoffAndFee(OptionTerms memory _optionTerms)
        internal
        pure
        override
        returns (uint256 adminFee, uint256 payoffAmount)
    {
        // TODO
    }

    // function _loanSanityChecksOffer(LoanData.Offer memory _offer) internal pure {
    //     ...
    // }
    function _optionSanityChecksOrder(OptionData.Order memory _order) internal pure {
        // Misc. option order sanity checks
        // TODO
    }
}
