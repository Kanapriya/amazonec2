// Copyright (c) 2018 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

import ballerina/io;
import ballerina/http;
import ballerina/time;
import ballerina/crypto;
import in2/crypt;


function AmazonEC2Connector::monitorInstances() returns Instances|AmazonEC2Error {

    endpoint http:Client clientEndpoint = self.clientEndpoint;

    AmazonEC2Error amazonEC2Error = {};
    string signature;
    string httpMethod;
    string requestURI;
    string host;
    string amazonEndpoint;

    http:Request request = new;

    httpMethod = "GET";
    requestURI = "/";
    host = "ec2.amazonaws.com";
    amazonEndpoint = "https://"+host;
    string canonicalQueryString = "Action=MonitorInstances&InstanceId.1=i-05ec3e7f41474a60d&Version=2016-11-15";
    generateSignature(request, self.accessKeyId, self.secretAccessKey, self.region, GET, requestURI, "", canonicalQueryString);

    var httpResponse = clientEndpoint->get("/?Action=MonitorInstances&InstanceId.1=i-05ec3e7f41474a60d&Version=2016-11-15", message = request);
    io:println(httpResponse);
    match httpResponse {
        error err => {
            amazonEC2Error.message = err.message;
            return amazonEC2Error;
        }
        http:Response response => {
            var amazonResponse = response.getXmlPayload();
            match amazonResponse {
                error err => {
                    amazonEC2Error.message = err.message;
                    return amazonEC2Error;
                }
                xml xmlResponse => {
                    Instances instance = {};
                    return instance;
                }
            }
        }
    }
}