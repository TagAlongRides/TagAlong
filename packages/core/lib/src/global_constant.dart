enum Environment { production, test }

const runEnvironment = Environment.production; // UPDATE TO RUN IN CLOUD ENV OR LOCALLY

const baseUrl = 'https://us-central1-tagalong-1c5fb.cloudfunctions.net/cloudfunction';
const testUrl = 'http://10.0.2.2:5001/tagalong-1c5fb/us-central1/cloudfunction';
const apiVersion = '/api/v1/';

const stripeConnectRefreshUrl = 'https://www.refreshurl.com';
const stripeConnectReturnUrl = 'https://www.returnurl.com';
