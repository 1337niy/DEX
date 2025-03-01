// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/**
 * @title Pair
 * @dev Контракт пула ликвидности для пары токенов.
 */
contract Pair {
    using SafeMath for uint256;

    // Адреса токенов в паре
    address public token0;
    address public token1;

    // Резервы токенов
    uint256 public reserve0;
    uint256 public reserve1;

    // Общее количество LP-токенов
    uint256 public totalSupply;

    // Балансы LP-токенов пользователей
    mapping(address => uint256) public balanceOf;

    // События
    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );

    /**
     * @dev Конструктор контракта.
     * @param _token0 Адрес первого токена.
     * @param _token1 Адрес второго токена.
     */
    constructor(address _token0, address _token1) {
        token0 = _token0;
        token1 = _token1;
    }

    /**
     * @dev Функция для добавления ликвидности.
     * @param amount0Desired Желаемое количество token0.
     * @param amount1Desired Желаемое количество token1.
     * @return amount0 Фактическое количество token0.
     * @return amount1 Фактическое количество token1.
     * @return liquidity Количество выпущенных LP-токенов.
     */
    function addLiquidity(uint256 amount0Desired, uint256 amount1Desired)
        external
        returns (uint256 amount0, uint256 amount1, uint256 liquidity)
    {
        (amount0, amount1) = _calculateLiquidity(amount0Desired, amount1Desired);
        liquidity = _mintLiquidity(msg.sender, amount0, amount1);
        _updateReserves();
        emit Mint(msg.sender, amount0, amount1);
    }

    /**
     * @dev Функция для удаления ликвидности.
     * @param liquidity Количество LP-токенов для сжигания.
     * @param to Адрес, на который будут отправлены токены.
     * @return amount0 Количество token0.
     * @return amount1 Количество token1.
     */
    function removeLiquidity(uint256 liquidity, address to)
        external
        returns (uint256 amount0, uint256 amount1)
    {
        require(balanceOf[msg.sender] >= liquidity, "Pair: INSUFFICIENT_LIQUIDITY");
        amount0 = (liquidity * reserve0) / totalSupply;
        amount1 = (liquidity * reserve1) / totalSupply;
        _burnLiquidity(msg.sender, liquidity);
        IERC20(token0).transfer(to, amount0);
        IERC20(token1).transfer(to, amount1);
        _updateReserves();
        emit Burn(msg.sender, amount0, amount1, to);
    }

    /**
     * @dev Функция для обмена токенов.
     * @param amount0Out Количество token0 для вывода.
     * @param amount1Out Количество token1 для вывода.
     * @param to Адрес, на который будут отправлены токены.
     */
    function swap(uint256 amount0Out, uint256 amount1Out, address to) external {
        require(amount0Out > 0 || amount1Out > 0, "Pair: INSUFFICIENT_OUTPUT_AMOUNT");
        require(amount0Out < reserve0 && amount1Out < reserve1, "Pair: INSUFFICIENT_LIQUIDITY");

        uint256 amount0In = IERC20(token0).balanceOf(address(this)) - reserve0;
        uint256 amount1In = IERC20(token1).balanceOf(address(this)) - reserve1;

        require(amount0In > 0 || amount1In > 0, "Pair: INSUFFICIENT_INPUT_AMOUNT");

        // Проверка инварианта AMM
        uint256 balance0 = reserve0 - amount0Out + amount0In;
        uint256 balance1 = reserve1 - amount1Out + amount1In;
        require(balance0 * balance1 >= reserve0 * reserve1, "Pair: K");

        if (amount0Out > 0) IERC20(token0).transfer(to, amount0Out);
        if (amount1Out > 0) IERC20(token1).transfer(to, amount1Out);

        _updateReserves();
        emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
    }

    /**
     * @dev Внутренняя функция для расчета количества токенов при добавлении ликвидности.
     * @param amount0Desired Желаемое количество token0.
     * @param amount1Desired Желаемое количество token1.
     * @return amount0 Фактическое количество token0.
     * @return amount1 Фактическое количество token1.
     */
    function _calculateLiquidity(uint256 amount0Desired, uint256 amount1Desired)
        internal
        view
        returns (uint256 amount0, uint256 amount1)
    {
        if (totalSupply == 0) {
            amount0 = amount0Desired;
            amount1 = amount1Desired;
        } else {
            uint256 amount1Optimal = (amount0Desired * reserve1) / reserve0;
            if (amount1Optimal <= amount1Desired) {
                amount0 = amount0Desired;
                amount1 = amount1Optimal;
            } else {
                uint256 amount0Optimal = (amount1Desired * reserve0) / reserve1;
                amount0 = amount0Optimal;
                amount1 = amount1Desired;
            }
        }
    }

    /**
     * @dev Внутренняя функция для выпуска LP-токенов.
     * @param to Адрес, на который будут зачислены LP-токены.
     * @param amount0 Количество token0.
     * @param amount1 Количество token1.
     * @return liquidity Количество выпущенных LP-токенов.
     */
    function _mintLiquidity(address to, uint256 amount0, uint256 amount1) internal returns (uint256 liquidity) {
        if (totalSupply == 0) {
            liquidity = sqrt(amount0 * amount1);
        } else {
            liquidity = min((amount0 * totalSupply) / reserve0, (amount1 * totalSupply) / reserve1);
        }
        balanceOf[to] += liquidity;
        totalSupply += liquidity;
    }

    /**
     * @dev Внутренняя функция для сжигания LP-токенов.
     * @param from Адрес, с которого будут сожжены LP-токены.
     * @param liquidity Количество LP-токенов для сжигания.
     */
    function _burnLiquidity(address from, uint256 liquidity) internal {
        balanceOf[from] -= liquidity;
        totalSupply -= liquidity;
    }

    /**
     * @dev Внутренняя функция для обновления резервов.
     */
    function _updateReserves() internal {
        reserve0 = IERC20(token0).balanceOf(address(this));
        reserve1 = IERC20(token1).balanceOf(address(this));
    }

    /**
     * @dev Вспомогательная функция для вычисления минимума из двух чисел.
     * @param a Первое число.
     * @param b Второе число.
     * @return Минимальное значение.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Вспомогательная функция для вычисления квадратного корня.
     * @param y Число, из которого извлекается корень.
     * @return z Квадратный корень.
     */
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}
