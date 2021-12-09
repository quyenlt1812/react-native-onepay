# react-native-onepay

Hash secure key and generate pay url for onepay

## Installation

```sh
npm install react-native-onepay

or

yarn add react-native-onepay
```

## Usage

```js
import OnepayHash from 'react-native-onepay-hash';

const [result, setResult] = useState<string>();

useEffect(() => {
  OnepayHash.generateURL({
    version: '2',
    command: 'pay',
    accessCode: '6BEB2546',
    merchant: 'TESTONEPAY',
    locale: 'en',
    returnUrl: 'https://localhost/returnurl',
    orderInfo: '123214125125',
    amount: '1000000',
    title: 'Test Payment',
    currency: 'VND',
    secretKey: '6D0870CDE5F24F34F3915FB0045120DB',
    baseUrl: 'https://mtf.onepay.vn/',
    merchTxnRef: new Date().getTime().toString(),
    againLink: 'https://scanme.eastplayers.io/cancel-payment',
    cardList: 'INTERNATIONAL',
  }).then((res) => setResult(res));
}, []);

 // ...

```

## Props
| Prop | Type | Default | Note |
|---|---|---|---|
| `version` | `String` | `2` | Version module of payment gateway |
| `command` | `String` | `pay` | Payment Function, value is “pay” |
| `accessCode` | `String` |  | Unique value for each merchant provided by OnePAY |
| `merchant` | `String` |  | Unique value for each merchant provided by OnePAY |
| `locale` | `String` |  | Language is used on the payment site Vietnamese: vn, English: en |
| `returnUrl` | `String` |  | Merchant’s URL Website for redirectresponse | 
| `orderInfo` | `String` |  | Order infomation, it could be an order number or brief description of order |
| `amount` | `String` |  | The amount of the transaction, this value does not have decimal comma. Add “00” before redirect to payment gateway. If transaction amount is VND 25,000 then the amount is 2500000 (Add "00" will be handled by the package) |
| `title` | `String` |  | Title of payment gateway is shown on the cardholder’s browser |
| `currency` | `String` |  | Payment Currency |
| `secretKey` | `String` |  |  |
| `baseUrl` | `String` |  |  |
| `merchTxnRef` | `String` |  | A unique value is created by merchant then send to OnePAY |
| `againLink` | `String` |  | The link of website before redirecting to OnePAY |
| `cardList` | `INTERNATIONAL`, `DOMESTIC` |  |  |
| `customerId?` | `String` |  | Customer's id. This one will be used to save customer's card on OnePAY |
| `customerEmail?` | `String` |  | Customer's email |
| `customerPhone?` | `String` |  | Customer's phone |

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT
