export class TranscriptionEntity {
    id: string;
    who: string;
    text: string;
    translations: string;
    when: string;
}

export class CallEntity {
    callid: string;
    text: string;
    when: string;
}

export class LanguageEntity {
    key: string;
    text: string;
}
