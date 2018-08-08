//
// Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

import ballerina/io;
import ballerina/time;
import ballerina/http;
import ballerina/crypto;
import ballerina/system;
import in2/crypt;

function generateSignature(http:Request request, string accessKeyId, string secretAccessKey, string region,
                           string httpVerb, string requestURI, string payload,   string canonicalQueryString) {
    string canonicalRequest;
    //string canonicalQueryString;
    string stringToSign;
    string payloadBuilder;
    string payloadStrBuilder;
    string authHeader;
    string amzDate;
    string shortDate;
    string signedHeader;
    string canonicalHeaders;
    string signedHeaders;
    string requestPayload;
    string signingKey;
    string encodedrequestURIValue;
    string signValue;
    string encodedSignValue;

    time:Time time = time:currentTime().toTimezone("GMT");
    amzDate = time.format(ISO8601_BASIC_DATE_FORMAT);
    shortDate = time.format(SHORT_DATE_FORMAT);
    request.setHeader(CONTENT_TYPE, "application/x-www-form-urlencoded; charset=utf-8");
    request.setHeader(X_AMZ_DATE, amzDate);
    request.setHeader(HOST, "ec2.amazonaws.com");

    canonicalRequest = httpVerb;
    canonicalRequest = canonicalRequest + "\n";
    encodedrequestURIValue = check http:encode(requestURI, UTF_8);
    canonicalRequest = canonicalRequest + encodedrequestURIValue.replace("%2F", "/");
    canonicalRequest = canonicalRequest + "\n";
    canonicalRequest = canonicalRequest + canonicalQueryString;
    canonicalRequest = canonicalRequest + "\n";

    if (payload != "" && payload != UNSIGNED_PAYLOAD){
        canonicalHeaders = canonicalHeaders + CONTENT_TYPE.toLower();
        canonicalHeaders = canonicalHeaders + ":";
        canonicalHeaders = canonicalHeaders + request.getHeader(CONTENT_TYPE.toLower());
        canonicalHeaders = canonicalHeaders + "\n";
        signedHeader = signedHeader + CONTENT_TYPE.toLower();
        signedHeader = signedHeader + ";";
    }

    if (payload == UNSIGNED_PAYLOAD){
        canonicalHeaders = canonicalHeaders + X_AMZ_CONTENT_SHA256.toLower();
        canonicalHeaders = canonicalHeaders + ":";
        canonicalHeaders = canonicalHeaders + request.getHeader(X_AMZ_CONTENT_SHA256.toLower());
        canonicalHeaders = canonicalHeaders + "\n";
        signedHeader = signedHeader + X_AMZ_CONTENT_SHA256.toLower();
        signedHeader = signedHeader + ";";
    }

    canonicalHeaders = canonicalHeaders + HOST.toLower();
    canonicalHeaders = canonicalHeaders + ":";
    canonicalHeaders = canonicalHeaders + request.getHeader(HOST.toLower());
    canonicalHeaders = canonicalHeaders + "\n";
    signedHeader = signedHeader + HOST.toLower();
    signedHeader = signedHeader + ";";

    canonicalHeaders = canonicalHeaders + X_AMZ_DATE.toLower();
    canonicalHeaders = canonicalHeaders + ":";
    canonicalHeaders = canonicalHeaders + request.getHeader(X_AMZ_DATE.toLower());
    canonicalHeaders = canonicalHeaders + "\n";
    signedHeader = signedHeader + X_AMZ_DATE.toLower();
    signedHeader = signedHeader;

    canonicalRequest = canonicalRequest + canonicalHeaders;
    canonicalRequest = canonicalRequest + "\n";
    signedHeaders = "";
    signedHeaders = signedHeader;
    canonicalRequest = canonicalRequest + signedHeaders;
    canonicalRequest = canonicalRequest + "\n";
    payloadBuilder = payload;
    requestPayload = "";
    requestPayload = payloadBuilder;

    if (payloadBuilder == UNSIGNED_PAYLOAD) {
        requestPayload = "";
    } else {
        requestPayload = crypto:hash(payloadBuilder, crypto:SHA256).toLower();
    }

    canonicalRequest = canonicalRequest + requestPayload;
    string canonicalRequestHash = crypto:hash(canonicalRequest, crypto:SHA256).toLower();
    //Start creating the string to sign

    stringToSign = stringToSign + AWS4_HMAC_SHA256;
    stringToSign = stringToSign + "\n";
    stringToSign = stringToSign + amzDate;
    stringToSign = stringToSign + "\n";
    stringToSign = stringToSign + shortDate;
    stringToSign = stringToSign + "/";
    stringToSign = stringToSign + region;
    stringToSign = stringToSign + "/";
    stringToSign = stringToSign + SERVICE_NAME;
    stringToSign = stringToSign + "/";
    stringToSign = stringToSign + TERMINATION_STRING;
    stringToSign = stringToSign + "\n";
    stringToSign = stringToSign + crypto:hash(canonicalRequest, crypto:SHA256).toLower();

    signValue = (AWS4 + secretAccessKey);

    encodedSignValue = check signValue.base64Encode();
    //signingKey = crypt:hmac(TERMINATION_STRING, crypt:hmac(SERVICE_NAME, crypt:hmac(region, crypt:hmac(shortDate,
    //"AWS4" + secretAccessKey, crypt:SHA256, keyType = crypt:BASE64), crypt:SHA256, keyType = crypt:BASE64),
    //crypt:SHA256, keyType = crypt:BASE64), crypt:SHA256, keyType = crypt:BASE64);

    string kDate = crypt:hmac(shortDate, "AWS4" + secretAccessKey, crypt:SHA256, keyType = crypt:BASE64);
    string kRegion = crypt:hmac(region, kDate,  crypt:SHA256, keyType = crypt:BASE64);
    string kService = crypt:hmac(SERVICE_NAME, kRegion,  crypt:SHA256, keyType = crypt:BASE64);
    signingKey = crypt:hmac("aws4_request", kService,  crypt:SHA256, keyType = crypt:BASE64);

    authHeader = authHeader + (AWS4_HMAC_SHA256);
    authHeader = authHeader + (" ");
    authHeader = authHeader + (CREDENTIAL);
    authHeader = authHeader + ("=");
    authHeader = authHeader + (accessKeyId);
    authHeader = authHeader + ("/");
    authHeader = authHeader + (shortDate);
    authHeader = authHeader + ("/");
    authHeader = authHeader + (region);
    authHeader = authHeader + ("/");
    authHeader = authHeader + (SERVICE_NAME);
    authHeader = authHeader + ("/");
    authHeader = authHeader + (TERMINATION_STRING);
    authHeader = authHeader + (",");
    authHeader = authHeader + (SIGNED_HEADER);
    authHeader = authHeader + ("=");
    authHeader = authHeader + (signedHeaders);
    authHeader = authHeader + (",");
    authHeader = authHeader + (SIGNATURE);
    authHeader = authHeader + ("=");

    authHeader = authHeader + crypt:hmac(stringToSign, signingKey, crypt:SHA256, keyType = crypt:BASE64).base64ToBase16Encode().toLower();
    request.setHeader(AUTHORIZATION, authHeader);
}
