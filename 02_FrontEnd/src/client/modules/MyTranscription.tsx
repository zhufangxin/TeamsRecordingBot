import * as React from "react";
import { Flex, Avatar, Card, CardHeader, CardBody, Text } from "@fluentui/react-northstar";
import * as PropTypes from "prop-types";
import { TranscriptionEntity } from "../Models/ModelEntities";
const MyTranscription = (props) => {
    console.log(props);
    return (
        <Card fluid selected>
            <CardHeader>
                <Flex gap= "gap.small" >
                    {/* <Avatar name={props.transcripion}/> */}
                    <Avatar name= "Bot"/>
                    <Flex column>
                        <Text content= "Bot" weight= "bold" />
                        <Text content= "Today" size= "small" />
                    </Flex>
                </Flex>
            </CardHeader>
            <CardBody>Bot
                <b>Translation:</b>Bot
            </CardBody>
        </Card>
    );
};

MyTranscription.propTypes = {
    transcription: TranscriptionEntity
};
export default MyTranscription;
