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
                    <Avatar name={props.transcripion.who}/>
                    <Flex column>
                        <Text content={props.transcription.who} weight= "bold" />
                        <Text content={new Date(Date.parse(props.transcription.when)).toLocaleString()} size= "small" />
                    </Flex>
                </Flex>
            </CardHeader>
            <CardBody>{props.transcription.text}
                <b>Translation:</b>{props.transcription.translations}
            </CardBody>
        </Card>
    );
};

MyTranscription.propTypes = {
    transcription: TranscriptionEntity
};
export default MyTranscription;
