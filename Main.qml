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
            startWaiting();
        }

        function onSendingFailed(reason){
            let message = "Sending failed: " +  reason + "\n"
            errorInfoTextArea.text = message + errorInfoTextArea.text;
            stopWaiting()
        }

        function onResponseHandled(data, status){
            replyStatusLabel.text = replyStatusLabel.prefixText + status;

            responseTextArea.text = data;
            stopWaiting()
        }

        function onResponseErrorOccur(reason){
            let message = "Handling failed: " + reason + "\n"
            errorInfoTextArea.text = message + errorInfoTextArea.text;
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

                TextField{
                    id: connectionUrl
                    anchors{
                        left: parent.left
                        right: parent.right
                    }

                    placeholderText: "Url to send request to"
                    // text: "https://httpbin.org/delay/1"
                    // text: "https://nghttp2.org/httpbin/delay/1"
                    text: "https://reqres.in/api/users"
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
                            text: "{\n  \"name\": \"morpheus\",\n  \"job\": \"leader\"\n}";
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
                            left: parent.left
                            top: parent.bottom
                            leftMargin: 2
                            topMargin: 5
                        }

                        readonly property string prefixText: "Response status: "
                        text: prefixText + "---"
                        font.pixelSize: 14
                        opacity: 0.4
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
                            id: errorInfoTextArea
                            placeholderText: "Error output"
                            readOnly: true
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
                    Backend.sendRequest(connectionUrl.text, requestTextArea.text);
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
