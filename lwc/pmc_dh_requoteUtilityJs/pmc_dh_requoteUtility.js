import { addItemToCart } from 'commerce/cartApi';

export function addMultipleItemsToCart(cartId, items) {
  const itemPromises = items.map(item => {
    const { productId, quantity } = item;
    const payload = {
      cartId,
      productId,
      quantity
    };

    return addItemToCart(payload);
  });

  Promise.all(itemPromises)
    .then(responses => {
      console.log('Items added to the cart:', responses);
    })
    .catch(error => {
      console.error('Failed to add items to cart:', error);
    });
}