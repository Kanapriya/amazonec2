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

documentation {
    AmazonEC2 Client object
    E{{}}
    F{{amazonEC2Config}} - AmazonEC2 connector configurations
    F{{amazonEC2Connector}} - AmazonEC2 Connector object
}
public type Client object {

    public AmazonEC2Configuration amazonEC2Config = {};
    public AmazonEC2Connector amazonEC2Connector = new;

    documentation {AmazonEC2 connector endpoint initialization function
        P{{config}} - AmazonEC2 connector configuration
    }
    public function init(AmazonEC2Configuration config);

    documentation {Return the AmazonEC2 connector client
        R{{}} - AmazonEC2 connector client
    }
    public function getCallerActions() returns AmazonEC2Connector;

};

public type AmazonEC2Connector object {
    string uri;
    public string accessKeyId;
    public string secretAccessKey;
    public string region;
    public http:Client clientEndpoint = new;

    public function monitorInstances() returns Instances|AmazonEC2Error;
};

public type AmazonEC2Configuration record {
    string uri;
    string accessKeyId;
    string secretAccessKey;
    string region;
    http:ClientEndpointConfig clientConfig = {};
};

public type Instances record {
    string [] instancesSet;
    string requestId;
};

public type AmazonEC2Error record {
    string message;
    error? cause;
    int statusCode;
};