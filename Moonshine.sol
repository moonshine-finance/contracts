// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8;

import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { Context } from "@openzeppelin/contracts/utils/Context.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { SafeMath } from "@openzeppelin/contracts/utils/math/SafeMath.sol";

import { IUniswapV2Factory } from "./interfaces/IUniswapV2Factory.sol";
import { IUniswapV2Pair } from "./interfaces/IUniswapV2Pair.sol";
import { IUniswapV2Router02 } from "./interfaces/IUniswapV2Router02.sol";

/**
 * Moonshine Finance 🌕
 *
 * █████████▓▓▓▓▓▓▓▓▓▓▓▓▓▓▒▒
 * ███████▓▓▓▓▓▓▓▓▒▒▒▒▒▒▒▒▓▓▒▒░░▒▒
 * ███████▓▓▓▓▓▓▓▓▒▒▒▒▒▒░░▒▒▒▒▒▒▒▒░░▓▓
 * ██████████▓▓▓▓▓▓▓▓▓▓▒▒▓▓▒▒▓▓▒▒▒▒░░░░░░▒▒
 * ████████▓▓▓▓▓▓▓▓▒▒▒▒▓▓▒▒▒▒▓▓▓▓▓▓░░░░░░░░░░
 * ████████▓▓▓▓▓▓▓▓▓▓▒▒▒▒▓▓▒▒▒▒░░▒▒░░░░░░░░░░░░▒▒
 * ████████▓▓██▒▒▒▒▒▒▒▒▒▒▒▒░░░░▒▒░░░░░░░░░░░░    ░░
 * ████████▓▓▓▓▒▒▓▓▒▒▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░  ░░▒▒
 * ████████▓▓▓▓▒▒▒▒▒▒▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░      ▒▒
 * ██████▓▓▓▓▓▓▒▒▒▒▒▒▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░        ▓▓
 * ██████▓▓▓▓▓▓▒▒▓▓▒▒▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░  ░░
 * ████▓▓▓▓▓▓▓▓▒▒▓▓▒▒▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  ░░
 * ▓▓██▓▓▓▓▓▓▒▒▒▒▒▒▒▒▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░          ▒▒
 * ████▓▓▓▓▓▓▒▒▒▒▒▒▓▓▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░    ░░
 * ██████▓▓▓▓▒▒▒▒▒▒▒▒▒▒▒▒░░░░░░░░░░░░  ░░░░░░░░░░░░░░░░      ▓▓
 * ████▓▓██▓▓▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░░░░▒▒░░░░░░░░░░░░░░░░░░░░░░    ▒▒
 * ██▓▓▓▓▓▓▓▓▓▓▒▒▒▒▒▒▒▒▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░
 * ██▓▓██▓▓▓▓▓▓▒▒▓▓▒▒▒▒▒▒▒▒░░▒▒░░░░░░▒▒░░░░░░░░░░░░░░░░░░
 * ████▓▓▓▓▓▓▓▓▓▓▓▓▓▓▒▒▒▒▓▓░░▒▒░░░░░░░░▒▒░░░░░░░░              ▓▓
 * ████▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▒▒▒▒▒▒▒▒░░░░░░░░░░░░░░░░░░              ░░
 * ██████▓▓▓▓▓▓▓▓▓▓▓▓▓▓▒▒▒▒▒▒▒▒▒▒▒▒░░░░░░░░░░░░░░░░░░    ░░░░  ░░
 * ████▓▓██▓▓▓▓▓▓▓▓▓▓▓▓▒▒▒▒▒▒▒▒▒▒▒▒░░░░░░░░░░░░░░░░
 * ▓▓████▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▒▒▒▒▒▒░░░░▒▒░░░░░░░░░░░░░░░░░░░░░░    ░░
 * ████████▓▓▓▓▓▓▓▓▒▒▓▓▓▓▒▒▒▒▒▒▒▒▒▒░░░░░░░░░░░░  ░░░░    ░░
 * ████████▓▓▓▓▒▒▓▓▓▓▓▓▒▒▓▓▒▒▒▒▒▒░░▒▒░░░░░░░░░░░░░░░░░░░░  ░░░░░░
 * ██████▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▒▒░░▒▒░░░░░░░░░░░░░░░░░░░░░░░░        ░░
 * ██████▓▓▓▓██▓▓▓▓▓▓▓▓▓▓▒▒░░▒▒▒▒░░▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░▒▒
 * ██████▓▓██▓▓▓▓▓▓▓▓▒▒▒▒▒▒▒▒▒▒░░▒▒░░░░░░░░░░░░░░░░  ░░        ▓▓
 * ████████▓▓██▓▓▓▓▓▓▒▒▓▓░░▒▒░░▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
 * ██████▓▓██▓▓▓▓▒▒▒▒▒▒▒▒░░░░░░▒▒░░░░░░░░░░░░░░░░░░░░░░
 * ████▓▓▓▓▓▓▓▓▓▓▒▒▒▒▓▓▒▒▒▒░░░░░░▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░▒▒
 * ▓▓████▓▓▓▓▓▓▓▓▓▓▓▓▒▒▒▒▒▒░░░░▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░
 * ▓▓▓▓▓▓▓▓▓▓▓▓▒▒▓▓▓▓▒▒▒▒▒▒░░░░░░░░░░░░░░  ░░░░░░  ░░  ░░  ░░
 * ████▓▓▓▓▓▓▓▓▒▒▓▓▓▓▒▒▒▒▒▒░░░░░░░░░░░░░░  ░░        ░░░░
 * ████▓▓██▓▓▓▓▒▒▓▓▓▓▓▓▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
 * ████▓▓██▓▓▓▓▒▒▓▓▒▒▓▓▒▒▒▒░░░░░░░░░░░░░░░░░░░░    ░░░░░░
 * ██████▓▓▓▓▒▒▒▒▒▒▒▒▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
 * ██████▓▓▓▓▒▒▒▒▓▓▒▒▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░
 * ██▓▓▓▓██▓▓▓▓▒▒▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▓▓
 * ▓▓██▓▓▓▓▓▓▒▒▓▓▒▒▒▒▒▒░░▒▒░░░░░░░░░░░░░░░░░░▒▒▒▒
 * ████▓▓▓▓▓▓▒▒▒▒▒▒▒▒▒▒▒▒░░░░░░░░░░░░░░░░░░░░▒▒
 * ██████▓▓▓▓▓▓▒▒▒▒▒▒▒▒▒▒░░░░░░░░░░▒▒▒▒░░░░▓▓
 * ██████▓▓▒▒▓▓▒▒▒▒▒▒▒▒▒▒░░░░░░░░░░▒▒░░▒▒
 * ██████▓▓▓▓▓▓▓▓▒▒▒▒▒▒░░░░░░▒▒▒▒▒▒▒▒▓▓
 * ████████▓▓▓▓▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▓▓
 * ████████▓▓▓▓▒▒▓▓▒▒▓▓▒▒▓▓▓▓
 *
 * Are they among us? 👽
 */
contract Moonshine is Context, IERC20, IERC20Metadata, Ownable {
	using SafeMath for uint256;
	using Address for address;

	string private _name = "Moonshine";
	string private _symbol = unicode"🌕";
	uint8 private _decimals = 9;

	mapping(address => uint256) private _rOwned;
	mapping(address => uint256) private _tOwned;

	mapping(address => mapping(address => uint256)) private _allowances;

	mapping(address => bool) private _isExcludedFromFee;
	mapping(address => bool) private _isExcluded;

	address[] private _excluded;

	uint256 private constant MAX = ~uint256(0);
	uint256 private _tTotal = 69 * 10**6 * 10**9;
	uint256 private _rTotal = (MAX - (MAX % _tTotal));

	uint256 public _maxTxAmount = 3 * 10**6 * 10**9;
	uint256 public numTokensSellToAddToLiquidity = 3 * 10**5 * 10**9;

	uint256 private _tFeeTotal;
	uint256 public _taxFee = 0;
	uint256 private _previousTaxFee = _taxFee;
	uint256 public _liquidityFee = 6;
	uint256 private _previousLiquidityFee = _liquidityFee;

	bool inSwapAndLiquify;
	bool public swapAndLiquifyEnabled = true;

	IUniswapV2Router02 public immutable router;
	IUniswapV2Pair public immutable pair;

	event TaxFeeUpdated(uint256 taxFee);
	event LiquidityFeeUpdated(uint256 liquidityFee);
	event ExcludeFromRewardUpdated(address account);
	event IncludeInRewardUpdated(address account);
	event ExcludeFromFeeUpdated(address account);
	event IncludeInFeeUpdated(address account);
	event MaxTxAmountUpdated(uint256 _maxTxAmount);
	event SwapAndLiquifyEnabledUpdated(bool enabled);
	event NumTokensSellToAddToLiquidityUpdated(uint256 _numTokensSellToAddToLiquidity);
	event SwapAndLiquify(uint256 tokensSwapped, uint256 maticReceived, uint256 tokensIntoLiqudity);

	modifier lockTheSwap {
		inSwapAndLiquify = true;
		_;
		inSwapAndLiquify = false;
	}

	constructor(address __router) {
		_rOwned[_msgSender()] = _rTotal;

		IUniswapV2Router02 _router = IUniswapV2Router02(__router);
		// create a UNI_V2-like pair for this new token
		pair = IUniswapV2Pair(IUniswapV2Factory(_router.factory()).createPair(address(this), _router.WETH()));

		// set the rest of the contract variables
		router = _router;

		// exclude only this contract and deployer from fees
		_isExcludedFromFee[address(this)] = true;
		_isExcludedFromFee[_msgSender()] = true;

		emit Transfer(address(0), _msgSender(), _tTotal);
	}

	// Needed to receive MATIC from router in swaps
	receive() external payable {}

	function name() public view override returns (string memory) {
		return _name;
	}

	function symbol() public view override returns (string memory) {
		return _symbol;
	}

	function decimals() public view override returns (uint8) {
		return _decimals;
	}

	function totalSupply() public view override returns (uint256) {
		return _tTotal;
	}

	function balanceOf(address account) public view override returns (uint256) {
		if (_isExcluded[account]) return _tOwned[account];
		return tokenFromReflection(_rOwned[account]);
	}

	function transfer(address recipient, uint256 amount) public override returns (bool) {
		_transfer(_msgSender(), recipient, amount);
		return true;
	}

	function allowance(address owner, address spender) public view override returns (uint256) {
		return _allowances[owner][spender];
	}

	function approve(address spender, uint256 amount) public override returns (bool) {
		_approve(_msgSender(), spender, amount);
		return true;
	}

	function transferFrom(
		address sender,
		address recipient,
		uint256 amount
	) public override returns (bool) {
		_transfer(sender, recipient, amount);
		_approve(
			sender,
			_msgSender(),
			_allowances[sender][_msgSender()].sub(amount, "Moonshine::tranferFrom: Transfer amount exceeds allowance")
		);
		return true;
	}

	function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
		_approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
		return true;
	}

	function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
		_approve(
			_msgSender(),
			spender,
			_allowances[_msgSender()][spender].sub(
				subtractedValue,
				"Moonshine::decreaseAllowance: Decreased allowance below zero"
			)
		);
		return true;
	}

	function isExcludedFromReward(address account) public view returns (bool) {
		return _isExcluded[account];
	}

	function totalFees() public view returns (uint256) {
		return _tFeeTotal;
	}

	function deliver(uint256 tAmount) public {
		address sender = _msgSender();
		require(!_isExcluded[sender], "Moonshine::deliver: Excluded addresses cannot call this function");
		(uint256 rAmount, , , , , ) = _getValues(tAmount);
		_rOwned[sender] = _rOwned[sender].sub(rAmount);
		_rTotal = _rTotal.sub(rAmount);
		_tFeeTotal = _tFeeTotal.add(tAmount);
	}

	function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns (uint256) {
		require(tAmount <= _tTotal, "Moonshine::reflectionFromToken: Amount must be less than supply");
		if (!deductTransferFee) {
			(uint256 rAmount, , , , , ) = _getValues(tAmount);
			return rAmount;
		} else {
			(, uint256 rTransferAmount, , , , ) = _getValues(tAmount);
			return rTransferAmount;
		}
	}

	function tokenFromReflection(uint256 rAmount) public view returns (uint256) {
		require(rAmount <= _rTotal, "Moonshine::tokenFromReflection: Amount must be less than total reflections");
		uint256 currentRate = _getRate();
		return rAmount.div(currentRate);
	}

	function excludeFromReward(address account) public onlyOwner {
		require(!_isExcluded[account], "Moonshine::excludeFromReward: Account is already excluded");
		if (_rOwned[account] > 0) {
			_tOwned[account] = tokenFromReflection(_rOwned[account]);
		}
		_isExcluded[account] = true;
		_excluded.push(account);
		emit ExcludeFromRewardUpdated(account);
	}

	function includeInReward(address account) external onlyOwner {
		require(_isExcluded[account], "Moonshine::includeInReward: Account is already excluded");
		for (uint256 i = 0; i < _excluded.length; i++) {
			if (_excluded[i] == account) {
				_excluded[i] = _excluded[_excluded.length - 1];
				_tOwned[account] = 0;
				_isExcluded[account] = false;
				_excluded.pop();
				break;
			}
		}
		emit IncludeInRewardUpdated(account);
	}

	function _transferBothExcluded(
		address sender,
		address recipient,
		uint256 tAmount
	) private {
		(
			uint256 rAmount,
			uint256 rTransferAmount,
			uint256 rFee,
			uint256 tTransferAmount,
			uint256 tFee,
			uint256 tLiquidity
		) = _getValues(tAmount);
		_tOwned[sender] = _tOwned[sender].sub(tAmount);
		_rOwned[sender] = _rOwned[sender].sub(rAmount);
		_tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
		_rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
		_takeLiquidity(tLiquidity);
		_reflectFee(rFee, tFee);

		emit Transfer(sender, recipient, tTransferAmount);
	}

	function excludeFromFee(address account) public onlyOwner {
		_isExcludedFromFee[account] = true;
		emit ExcludeFromFeeUpdated(account);
	}

	function includeInFee(address account) public onlyOwner {
		_isExcludedFromFee[account] = false;
		emit IncludeInFeeUpdated(account);
	}

	function setTaxFeePercent(uint256 taxFee) external onlyOwner {
		require(taxFee <= 6, "Moonshine::setTaxFeePercent: Amount must be less than or equal to 6");
		_taxFee = taxFee;

		emit TaxFeeUpdated(taxFee);
	}

	function setLiquidityFeePercent(uint256 liquidityFee) external onlyOwner {
		require(liquidityFee <= 9, "Moonshine::setLiquidityFeePercent: Amount must be less than or equal to 9");
		_liquidityFee = liquidityFee;

		emit LiquidityFeeUpdated(liquidityFee);
	}

	function setMaxTxPercent(uint256 maxTxPercent) external onlyOwner {
		require(maxTxPercent > 0, "Moonshine::setMaxTxPercent: Amount must be greater than 0");
		_maxTxAmount = _tTotal.mul(maxTxPercent).div(10**2);

		emit MaxTxAmountUpdated(_maxTxAmount);
	}

	function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
		swapAndLiquifyEnabled = _enabled;
		emit SwapAndLiquifyEnabledUpdated(_enabled);
	}

	function setNumTokensSellToAddToLiquidity(uint256 _numTokensSellToAddToLiquidity)
		external
		onlyOwner
	{
		numTokensSellToAddToLiquidity = _numTokensSellToAddToLiquidity;
		emit NumTokensSellToAddToLiquidityUpdated(_numTokensSellToAddToLiquidity);
	}

	function _reflectFee(uint256 rFee, uint256 tFee) private {
		_rTotal = _rTotal.sub(rFee);
		_tFeeTotal = _tFeeTotal.add(tFee);
	}

	function _getValues(uint256 tAmount)
		private
		view
		returns (
			uint256,
			uint256,
			uint256,
			uint256,
			uint256,
			uint256
		)
	{
		(uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getTValues(tAmount);
		(uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, _getRate());
		return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tLiquidity);
	}

	function _getTValues(uint256 tAmount)
		private
		view
		returns (
			uint256,
			uint256,
			uint256
		)
	{
		uint256 tFee = calculateTaxFee(tAmount);
		uint256 tLiquidity = calculateLiquidityFee(tAmount);
		uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity);
		return (tTransferAmount, tFee, tLiquidity);
	}

	function _getRValues(
		uint256 tAmount,
		uint256 tFee,
		uint256 tLiquidity,
		uint256 currentRate
	)
		private
		pure
		returns (
			uint256,
			uint256,
			uint256
		)
	{
		uint256 rAmount = tAmount.mul(currentRate);
		uint256 rFee = tFee.mul(currentRate);
		uint256 rLiquidity = tLiquidity.mul(currentRate);
		uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity);
		return (rAmount, rTransferAmount, rFee);
	}

	function _getRate() private view returns (uint256) {
		(uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
		return rSupply.div(tSupply);
	}

	function _getCurrentSupply() private view returns (uint256, uint256) {
		uint256 rSupply = _rTotal;
		uint256 tSupply = _tTotal;
		for (uint256 i = 0; i < _excluded.length; i++) {
			if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
			rSupply = rSupply.sub(_rOwned[_excluded[i]]);
			tSupply = tSupply.sub(_tOwned[_excluded[i]]);
		}
		if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
		return (rSupply, tSupply);
	}

	function _takeLiquidity(uint256 tLiquidity) private {
		uint256 currentRate = _getRate();
		uint256 rLiquidity = tLiquidity.mul(currentRate);
		_rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
		if (_isExcluded[address(this)]) _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
	}

	function calculateTaxFee(uint256 _amount) private view returns (uint256) {
		return _amount.mul(_taxFee).div(10**2);
	}

	function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
		return _amount.mul(_liquidityFee).div(10**2);
	}

	function removeAllFee() private {
		if (_taxFee == 0 && _liquidityFee == 0) return;

		_previousTaxFee = _taxFee;
		_previousLiquidityFee = _liquidityFee;

		_taxFee = 0;
		_liquidityFee = 0;
	}

	function restoreAllFee() private {
		_taxFee = _previousTaxFee;
		_liquidityFee = _previousLiquidityFee;
	}

	function isExcludedFromFee(address account) public view returns (bool) {
		return _isExcludedFromFee[account];
	}

	function _approve(
		address owner,
		address spender,
		uint256 amount
	) private {
		require(owner != address(0), "Moonshine::_approve: Approve from the zero address");
		require(spender != address(0), "Moonshine::_approve: Approve to the zero address");

		_allowances[owner][spender] = amount;
		emit Approval(owner, spender, amount);
	}

	function _transfer(
		address from,
		address to,
		uint256 amount
	) private {
		require(from != address(0), "Moonshine::_transfer: Transfer from the zero address");
		require(to != address(0), "Moonshine::_transfer: Transfer to the zero address prohibited");
		require(amount > 0, "Moonshine::_transfer: Amount must be greater than zero");
		if (from != owner() && to != owner())
			require(amount <= _maxTxAmount, "Moonshine::_transfer: Amount exceeds the maxTxAmount.");

		// is the balance of this contract over the min number of tokens needed to initiate a swap + liquidity lock?
		uint256 contractTokenBalance = balanceOf(address(this));

		if (contractTokenBalance >= _maxTxAmount) {
			contractTokenBalance = _maxTxAmount;
		}

		bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
		// also, don't get caught in a circular liquidity event, and don't swap & liquify when sender is the pair
		if (overMinTokenBalance && !inSwapAndLiquify && from != address(pair) && swapAndLiquifyEnabled) {
			contractTokenBalance = numTokensSellToAddToLiquidity;
			// provide liquidity
			swapAndLiquify(contractTokenBalance);
		}

		// indicates if fee should be deducted from transfer
		bool takeFee = true;

		// if any account belongs to _isExcludedFromFee account then remove the fee
		if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
			takeFee = false;
		}

		// transfer amount, it will take tax, burn, liquidity fee
		_tokenTransfer(from, to, amount, takeFee);
	}

	function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
		// split the contract moonshine balance into halves
		uint256 moonshineHalf1 = contractTokenBalance.div(2);
		uint256 moonshineHalf2 = contractTokenBalance.sub(moonshineHalf1);

		// get the contract MATIC balance in order to avoid adding any liquidity received by the contract beforehand
		uint256 balanceBefore = address(this).balance;

		// swap moonshine for MATIC
		swapMoonshineForMATIC(moonshineHalf1);

		// how much MATIC did we actually receive?
		uint256 balanceAfter = address(this).balance.sub(balanceBefore);

		// add liquidity to pair
		distillateMoonshineForMATIC(moonshineHalf2, balanceAfter);

		emit SwapAndLiquify(moonshineHalf1, balanceAfter, moonshineHalf2);
	}

	function swapMoonshineForMATIC(uint256 moonshineAmount) private {
		// generate the pair path moonshine -> token
		address[] memory path = new address[](2);
		path[0] = address(this);
		path[1] = router.WETH();

		_approve(address(this), address(router), moonshineAmount);

		// make the swap
		router.swapExactTokensForETHSupportingFeeOnTransferTokens(
			moonshineAmount,
			0, // accept any amount of MATIC
			path,
			address(this),
			block.timestamp
		);
	}

	function swapMoonshineForTokens(uint256 moonshineAmount, address _token) private {
		// generate the pair path moonshine -> token
		address[] memory path = new address[](2);
		path[0] = address(this);
		path[1] = _token;

		_approve(address(this), address(router), moonshineAmount);

		// make the swap
		router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
			moonshineAmount,
			0, // accept any amount of token
			path,
			address(this),
			block.timestamp
		);
	}

	function distillateMoonshineForMATIC(uint256 moonshineAmount, uint256 maticAmount) private {
		// approve token transfer
		_approve(address(this), address(router), moonshineAmount);

		// add the liquidity
		router.addLiquidityETH{ value: maticAmount }(
			address(this),
			moonshineAmount,
			0, // slippage is unavoidable
			0, // slippage is unavoidable
			address(0),
			block.timestamp
		);
	}

	function distillateMoonshineForTokens(uint256 moonshineAmount, address _token, uint256 tokenAmount) private {
		// approve tokens transfers
		_approve(address(this), address(router), moonshineAmount);
		_approve(_token, address(router), tokenAmount);

		// add the liquidity
		router.addLiquidity(
			address(this),
			_token,
			moonshineAmount,
			tokenAmount,
			0, // slippage really is unavoidable with our special pair
			0,
			address(0),
			block.timestamp
		);
	}

	// This method is responsible for taking all fee, if takeFee is true
	function _tokenTransfer(
		address sender,
		address recipient,
		uint256 amount,
		bool takeFee
	) private {
		if (!takeFee) removeAllFee();

		if (_isExcluded[sender] && !_isExcluded[recipient]) {
			_transferFromExcluded(sender, recipient, amount);
		} else if (!_isExcluded[sender] && _isExcluded[recipient]) {
			_transferToExcluded(sender, recipient, amount);
		} else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
			_transferStandard(sender, recipient, amount);
		} else if (_isExcluded[sender] && _isExcluded[recipient]) {
			_transferBothExcluded(sender, recipient, amount);
		} else {
			_transferStandard(sender, recipient, amount);
		}

		if (!takeFee) restoreAllFee();
	}

	function _transferStandard(
		address sender,
		address recipient,
		uint256 tAmount
	) private {
		(
			uint256 rAmount,
			uint256 rTransferAmount,
			uint256 rFee,
			uint256 tTransferAmount,
			uint256 tFee,
			uint256 tLiquidity
		) = _getValues(tAmount);
		_rOwned[sender] = _rOwned[sender].sub(rAmount);
		_rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
		_takeLiquidity(tLiquidity);
		_reflectFee(rFee, tFee);
		emit Transfer(sender, recipient, tTransferAmount);
	}

	function _transferToExcluded(
		address sender,
		address recipient,
		uint256 tAmount
	) private {
		(
			uint256 rAmount,
			uint256 rTransferAmount,
			uint256 rFee,
			uint256 tTransferAmount,
			uint256 tFee,
			uint256 tLiquidity
		) = _getValues(tAmount);
		_rOwned[sender] = _rOwned[sender].sub(rAmount);
		_tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
		_rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
		_takeLiquidity(tLiquidity);
		_reflectFee(rFee, tFee);
		emit Transfer(sender, recipient, tTransferAmount);
	}

	function _transferFromExcluded(
		address sender,
		address recipient,
		uint256 tAmount
	) private {
		(
			uint256 rAmount,
			uint256 rTransferAmount,
			uint256 rFee,
			uint256 tTransferAmount,
			uint256 tFee,
			uint256 tLiquidity
		) = _getValues(tAmount);
		_tOwned[sender] = _tOwned[sender].sub(tAmount);
		_rOwned[sender] = _rOwned[sender].sub(rAmount);
		_rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
		_takeLiquidity(tLiquidity);
		_reflectFee(rFee, tFee);
		emit Transfer(sender, recipient, tTransferAmount);
	}
}
