import { NativeModules } from 'react-native';

export interface URLProps {
  version: string;
  command: string;
  accessCode: string;
  merchant: string;
  locale: string;
  returnUrl: string;
  orderInfo: string;
  amount: string;
  title: string;
  currency: string;
  secretKey: string;
  baseUrl: string;
  merchTxnRef: string;
  againLink: string;
  cardList: string;
  customerId?: string;
  customerName?: string;
  customerEmail?: string;
}

type OnepayHashType = {
  multiply(a: number, b: number): Promise<number>;
  generateURL(opProps: URLProps): string;
};

const { OnepayHash: Onepay } = NativeModules;

export default Onepay as OnepayHashType;
