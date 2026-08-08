/// The TagAlong API, served by the `api` Cloud Function in `functions/`.
///
/// The previous backend was the `cloudfunction` export of a Node 16 codebase
/// that lived outside this repository, at `.../cloudfunction` + `/api/v1/`.
/// It is left deployed so a rollback is just a change to these two lines.
const baseUrl = 'https://us-central1-tagalong-1c5fb.cloudfunctions.net/api';
const apiVersion = '/v1/';

const stripeConnectRefreshUrl = 'https://www.refreshurl.com';
const stripeConnectReturnUrl = 'https://www.returnurl.com';
