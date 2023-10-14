const httpBaseUrl = String.fromEnvironment(
  'BASE_URL',
  defaultValue: 'http://192.168.178.21:3000/',
);

const httpToken = String.fromEnvironment('TOKEN', defaultValue: 'TEST_TOKEN');
