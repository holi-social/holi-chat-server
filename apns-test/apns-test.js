const fs = require('fs');
const jwt = require("jsonwebtoken");
const http2 = require('http2');

// follows https://docs.expo.dev/push-notifications/sending-notifications-custom/#apns-server
// currently runs into a HTTP 400 BAD REQUEST

const IS_PRODUCTION = true

const required = (name) => {
    if (!process.env[name]) {
        throw new Error(`Missing required environment variable: ${name}`);
    }
    const value = process.env[name]
    console.debug(`Using required env var ${name} with value ${value}`)
    return value;
}

if (process.argv.length === 1) {
    console.error('Usage: node apns-test.js <nativeDeviceToken>');
    process.exit(1);
}

const nativeDeviceToken = process.argv[2];
console.debug('nativeDeviceToken', nativeDeviceToken);
const authorizationToken = jwt.sign(
  {
    iss: required("APNS_TEAM_ID"),
    iat: Math.round(new Date().getTime() / 1000),
  },
  fs.readFileSync(required("APNS_KEYFILE"), "utf8"),
  {
    header: {
      alg: "ES256",
      kid: required("APNS_KEY_ID"),
    },
  }
);

console.debug('authorizationToken', authorizationToken)

const client = http2.connect(
  IS_PRODUCTION ? 'https://api.push.apple.com' : 'https://api.sandbox.push.apple.com'
);
client.on('error', (err) => console.error(err))

const request = client.request({
  ':method': 'POST',
  ':scheme': 'https',
  'apns-topic': required('APNS_TOPIC'), // = bundle identifier
  ':path': '/3/device/' + nativeDeviceToken, // This is the native device token you grabbed client-side
  authorization: `bearer ${authorizationToken}`, // This is the JSON web token generated in the "Authorization" step
});
request.setEncoding('utf8');

request.write(
  JSON.stringify({
    aps: {
      alert: {
        title: "📧 You've got mail!",
        body: 'Hello world! 🌐',
      },
    },
    experienceId: '@holistic-foundation/projectholi', // correct
    scopeKey: '@holistic-foundation/projectholi', // correct
  })
);
request.end();

let data = ''
request.on('response', (headers) => {
    // we can log each response header here
    for (const name in headers) {
      console.log(`${name}: ${headers[name]}`)
    }
})
request.on('data', (chunk) => { data += chunk })
request.on('end', () => {
    console.log(`\n${data}`)
    // In this case, we don't want to make any more
    // requests, so we can close the session
    client.close()
})
