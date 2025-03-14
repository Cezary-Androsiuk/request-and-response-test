import QtQuick
import QtQuick.Controls.Material

ApplicationWindow {
    height: Screen.height * 0.6
    width: Screen.width * 0.6
    minimumHeight: height
    minimumWidth: width
    maximumHeight: minimumHeight
    maximumWidth: minimumWidth

    visible: true
    title: qsTr("Request and Response Tester")

    Material.theme: Material.Dark
    Material.accent: Material.Pink // Purple

    Connections{
        target: Backend

        function onSendingFailed(reason){
            errorInfoTextArea.text = reason;
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
                topMargin: 20
                leftMargin: 30
                rightMargin: 30
                bottomMargin: 10
            }
            height: parent.height * 0.8

            Column{
                id: column
                anchors.fill: parent
                spacing: 20

                readonly property double textAreaHeight:
                    (column.height - connectionUrl.height - column.spacing*3) /3

                TextField{
                    id: connectionUrl
                    anchors{
                        left: parent.left
                        right: parent.right
                    }

                    placeholderText: "Url to send request to"
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
                            id: responseTextArea
                            placeholderText: "Response Data"
                            readOnly: true
                            text: "a\nb\n cca a \n asd a"

                            BusyIndicator{
                                id: waitingForResponseIndicator
                                anchors.centerIn: parent
                                running: false
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
                top: requestResponseArea.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                topMargin: 10
            }

            Button{
                id: sendRequestButton
                anchors{
                    verticalCenter: parent.verticalCenter
                }
                x: parent.width/2 - width - 10

                text: "Send request"

                onClicked: {
                    responseTextArea.text = "";
                    responseTextArea.enabled = false;
                    waitingForResponseIndicator.running = true;
                    cancelWaitingButton.enabled = true;
                    sendRequestButton.enabled = false;

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
                    cancelWaitingButton.enabled = false;
                    sendRequestButton.enabled = true;
                    responseTextArea.enabled = true;
                    waitingForResponseIndicator.running = false;
                }
            }
        }
    }

}
