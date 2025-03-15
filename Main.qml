import QtQuick
import QtQuick.Controls.Material
// WEB ENGINE STUFF
// import QtWebView
// import QtWebEngine

ApplicationWindow {
    height: Screen.height * 0.6
    width: Screen.width * 0.6
    minimumHeight: Screen.height * 0.6
    minimumWidth: Screen.width * 0.6
    // maximumHeight: minimumHeight
    // maximumWidth: minimumWidth

    visible: true
    title: qsTr("Request and Response Tester")

    Material.theme: Material.Dark
    Material.accent: Material.Pink // Purple

    function startWaiting(){
        replyDataLoader.sourceComponent = waitingForReply;

        cancelWaitingButton.enabled = true;
        sendRequestButton.enabled = false;
    }

    function stopWaiting(){
        // WEB ENGINE STUFF
        // var compiler = Backend.getCompiler();
        // if(compiler === "MSVC")
        // {
        //     if(Backend.getLastDataIsHtml())
        //         replyDataLoader.sourceComponent = htmlReply
        //     else
        //         replyDataLoader.sourceComponent = jsonReply
        // }
        // else
        // {
            replyDataLoader.sourceComponent = jsonReply
        // }

        cancelWaitingButton.enabled = false;
        sendRequestButton.enabled = true;
    }

    function time(){
        var now = new Date();
        return now.toLocaleDateString("YYYY-MM-DD") + " " + now.toLocaleTimeString() + " - "
    }

    function validStatus(status){
        return status < 0 ? "---" : status
    }

    Connections{
        target: Backend

        function onRequestSended(){
            // let message = "Sended!\n"
            // infoTextArea.text = message + infoTextArea.text;

            startWaiting();
        }

        function onSendingFailed(reason){
            let message = time() + "Sending failed: " +  reason + "\n"
            infoTextArea.text = message + infoTextArea.text;

            stopWaiting()
        }

        function onResponseHandled(){
            let message = time() + "OK\n"
            infoTextArea.text = message + infoTextArea.text;

            let status = Backend.getLastStatusCode();
            replyStatusLabel.text = replyStatusLabel.prefixText + validStatus(status);

            stopWaiting()
        }

        function onResponseErrorOccur(reason){
            let message = time() + "Handling failed: " + reason + "\n"
            infoTextArea.text = message + infoTextArea.text;

            let status = Backend.getLastStatusCode();
            replyStatusLabel.text = replyStatusLabel.prefixText + validStatus(status);

            stopWaiting()
        }

        function onAbortedRequest(){
            let message = time() + "Aborted\n"
            infoTextArea.text = message + infoTextArea.text;

            stopWaiting()
        }
    }

    Item{
        id: rootItem
        anchors.fill: parent

        Item{
            id: requestResponseArea
            anchors{
                top: parent.top
                left: parent.left
                right: parent.right
                bottom: controlArea.top
                topMargin: 20
                leftMargin: 30
                rightMargin: 30
            }

            Column{
                id: column
                anchors.fill: parent
                spacing: 20

                readonly property double textAreaHeight:
                    (column.height - connectionUrl.height - replyStatusLabel.height - column.spacing*3) /3

                Item{
                    anchors{
                        left: parent.left
                        right: parent.right
                    }
                    height: connectionUrl.height

                    TextField{
                        id: connectionUrl
                        anchors{
                            left: parent.left
                            top: parent.top
                            bottom: parent.bottom
                        }
                        width: parent.width * 0.85
                        font.family: "Courier New"

                        placeholderText: "Url to send request to"
                        // text: "https://httpbin.org/delay/1"
                        text: "https://reqres.in/api/users"
                        // text: "http://192.168.0.72:5000/api"
                    }

                    ComboBox{
                        id: requestMethodComboBox
                        anchors{
                            left: connectionUrl.right
                            top: parent.top
                            right: parent.right
                            bottom: parent.bottom
                        }

                        editable: false
                        model: ListModel{
                            id: model
                            ListElement { text: "GET" }
                            ListElement { text: "POST" }
                            ListElement { text: "PUT" }
                            ListElement { text: "PATCH" }

                            ListElement { text: "DELETE" }
                            ListElement { text: "HEAD" }
                            ListElement { text: "OPTIONS" }
                            ListElement { text: "TRACE" }
                            ListElement { text: "CONNECT" }
                        }
                        currentIndex: 1
                    }
                }



                Item{
                    anchors{
                        left: parent.left
                        right: parent.right
                    }
                    height: column.textAreaHeight
                    ScrollView{
                        anchors.fill: parent
                        TextArea{
                            id: requestTextArea
                            placeholderText: "Request Data"
                            text: "{\n"
                                + "    \"name\": \"morpheus\",\n"
                                + "    \"job\": \"leader\",\n"
                                + "    \"useful url 1\": \"https://httpbin.org/delay/1\",\n"
                                + "    \"useful url 2\": \"https://reqres.in/api/users\",\n"
                                + "    \"useful url 3\": \"http://192.168.0.72:5000/api\"\n"
                                + "}"
                            font.family: "Courier New"
                        }
                    }
                }


                Item{
                    anchors{
                        left: parent.left
                        right: parent.right
                    }
                    height: column.textAreaHeight

                    Loader{
                        id: replyDataLoader
                        anchors.fill: parent
                        onLoaded: {
                            var data = Backend.getLastData();

                            if(sourceComponent == waitingForReply)
                                return;

                            // WEB ENGINE STUFF
                            // if(sourceComponent == htmlReply)
                            // {
                            //     item.webViewHandler.loadHtml(data, "file:///")
                            // }
                            // else
                            // {
                                item.textAreaHandler.text = data;
                            // }
                        }
                    }

                    Label{
                        id: replyStatusLabel
                        anchors{
                            horizontalCenter: parent.horizontalCenter
                            top: parent.bottom
                            leftMargin: 2
                            topMargin: 5
                        }

                        readonly property string prefixText: "Response status: "
                        text: prefixText + "---"
                        font.pixelSize: 14
                        opacity: 0.8
                    }


                    Component{
                        id: jsonReply
                        Item{
                            id: jsonReplyContent
                            property alias textAreaHandler: responseTextArea

                            ScrollView{
                                id: responseScrollView
                                anchors.fill: parent
                                TextArea{
                                    id: responseTextArea
                                    placeholderText: "Response Data"
                                    // readOnly: true
                                    font.family: "Courier New"
                                }
                            }

                        }
                    }

                    // WEB ENGINE STUFF
                    // Component{
                    //     id: htmlReply
                    //     Item{
                    //         id: htmlReplyContent
                    //         property alias webViewHandler: webView

                    //         ScrollView{
                    //             anchors.fill: parent
                    //             // WebEngine{
                    //             WebView {
                    //                 id: webView
                    //             }

                    //         }
                    //     }
                    // }

                    Component{
                        id: waitingForReply
                        Item{
                            BusyIndicator{
                                anchors.centerIn: parent
                                running: true
                            }
                        }
                    }
                }


                Item{
                    anchors{
                        left: parent.left
                        right: parent.right
                    }
                    height: column.textAreaHeight
                    ScrollView{
                        anchors.fill: parent
                        TextArea{
                            id: infoTextArea
                            placeholderText: "Info output"
                            // readOnly: true
                            font.family: "Courier New"
                        }
                    }
                }
            }


        }

        Item{
            id: controlArea
            anchors{
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            height: 70

            Button{
                id: sendRequestButton
                anchors{
                    verticalCenter: parent.verticalCenter
                }
                x: parent.width/2 - width - 10

                text: "Send request"

                onClicked: {
                    Backend.sendRequest(
                                connectionUrl.text,
                                requestTextArea.text,
                                requestMethodComboBox.currentValue);
                }
            }

            Button{
                id: cancelWaitingButton
                anchors{
                    verticalCenter: parent.verticalCenter
                }
                x: parent.width/2 + 10

                text: "Cancel Waiting"

                enabled: false;

                onClicked: {
                    Backend.abortRequest();
                }
            }
        }
    }

}
