import QtQuick
import QtQuick.Controls.Material

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
        responseTextArea.text = "";

        responseScrollView.visible = false;
        waitingForResponseIndicator.visible = true;
        waitingForResponseIndicator.running = true;
        cancelWaitingButton.enabled = true;
        sendRequestButton.enabled = false;
    }

    function stopWaiting(){
        cancelWaitingButton.enabled = false;
        sendRequestButton.enabled = true;
        responseScrollView.visible = true;
        waitingForResponseIndicator.running = false;
        waitingForResponseIndicator.visible = false;
    }

    Connections{
        target: Backend

        function onRequestSended(){
            // let message = "Sended!\n"
            // infoTextArea.text = message + infoTextArea.text;
            startWaiting();
        }

        function onSendingFailed(reason){
            let message = "Sending failed: " +  reason + "\n"
            infoTextArea.text = message + infoTextArea.text;
            stopWaiting()
        }

        function onResponseHandled(data, status){
            let message = "OK\n"
            infoTextArea.text = message + infoTextArea.text;
            replyStatusLabel.text = replyStatusLabel.prefixText + status;

            responseTextArea.text = data;
            stopWaiting()
        }

        function onResponseErrorOccur(reason){
            let message = "Handling failed: " + reason + "\n"
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
                                + "    \"alternative URL\": \"https://httpbin.org/delay/1\"\n"
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

                    ScrollView{
                        id: responseScrollView
                        anchors.fill: parent
                        TextArea{
                            id: responseTextArea
                            placeholderText: "Response Data"
                            readOnly: true
                            font.family: "Courier New"
                        }
                    }

                    BusyIndicator{
                        id: waitingForResponseIndicator
                        anchors.centerIn: parent
                        running: false
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
                            readOnly: true
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

                }
            }
        }
    }

}
