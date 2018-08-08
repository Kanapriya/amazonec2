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

import ballerina/http;

function Client::init(AmazonEC2Configuration config) {
    config.uri ="https://ec2.amazonaws.com";
    self.amazonEC2Connector.accessKeyId = config.accessKeyId;
    self.amazonEC2Connector.secretAccessKey = config.secretAccessKey;
    self.amazonEC2Connector.region = config.region;
    config.clientConfig.url = config.uri;
    self.amazonEC2Connector.clientEndpoint.init(config.clientConfig);
}

function Client::getCallerActions() returns AmazonEC2Connector {
    return self.amazonEC2Connector;
}