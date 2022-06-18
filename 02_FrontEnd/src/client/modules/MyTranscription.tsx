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
                    <Avatar name={props.ranscripion}/>
                    <Flex column>
                        <Text content={props.ranscription} weight= "bold" />
                        <Text content={new Date(Date.parse(props.ranscription.when)).toLocaleString()} size= "small" />
                    </Flex>
                </Flex>
            </CardHeader>
            <CardBody>{props.ranscription.text}
                <b>Translation:</b>{props.ranscription.translations}
            </CardBody>
        </Card>
    );
};

MyTranscription.propTypes = {
    label: PropTypes.string,
    ranscription: TranscriptionEntity
};
export default MyTranscription;
