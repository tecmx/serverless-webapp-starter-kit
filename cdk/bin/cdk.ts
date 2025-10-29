#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
import { MainStack } from '../lib/main-stack';
import { UsEast1Stack } from '../lib/us-east-1-stack';

const app = new cdk.App();

interface EnvironmentProps {
  account: string;

  /**
   * Custom domain name for the webapp and Cognito.
   * You need to have a public Route53 hosted zone for the domain name in your AWS account.
   *
   * @default No custom domain name.
   */
  domainName?: string;

  /**
   * Use a NAT instance instead of NAT Gateways.
   * @default true
   */
  useNatInstance?: boolean;
}

// Detecta se está usando LocalStack
const useLocalStack = process.env.USE_LOCALSTACK === 'true';
const localStackAccount = '000000000000'; // Account ID padrão do LocalStack

const props: EnvironmentProps = {
  account: useLocalStack ? localStackAccount : process.env.CDK_DEFAULT_ACCOUNT!,
  // domainName: 'FIXME.example.com',
  useNatInstance: true,
};

if (useLocalStack) {
  console.log('🚀 Usando LocalStack para desenvolvimento local');
  console.log('   Endpoint: http://localhost:4566');
  console.log('   Account: ' + localStackAccount);
}

const virginia = new UsEast1Stack(app, 'ServerlessWebappStarterKitUsEast1Stack', {
  env: {
    account: props.account,
    region: 'us-east-1',
  },
  crossRegionReferences: true,
  domainName: useLocalStack ? undefined : props.domainName,
});
new MainStack(app, 'ServerlessWebappStarterKitStack', {
  env: {
    account: props.account,
    region: useLocalStack ? 'us-west-2' : process.env.CDK_DEFAULT_REGION,
  },
  crossRegionReferences: true,
  sharedCertificate: virginia.certificate,
  domainName: useLocalStack ? undefined : props.domainName,
  signPayloadHandler: virginia.signPayloadHandler,
});

// import { Aspects } from 'aws-cdk-lib';
// import { AwsSolutionsChecks } from 'cdk-nag';
// Aspects.of(app).add(new AwsSolutionsChecks());
