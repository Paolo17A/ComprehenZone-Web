class SpeechModel {
  String category;
  List<String> sentences;
  int index;

  SpeechModel(
      {required this.category, required this.sentences, required this.index});
}

SpeechModel? getSpeeechByIndex(int index) {
  for (var model in speechCategories) {
    if (model.index == index) {
      return model;
    }
  }
  return null;
}

List<SpeechModel> speechCategories = [
  SpeechModel(
      category: 'Diction',
      sentences: [
        "She sells seashells by the seashore.",
        "How can a clam cram in a clean cream can?",
        "Six slippery snails slid slowly seaward.",
        "Fuzzy Wuzzy was a bear. Fuzzy Wuzzy had no hair",
        "I saw Susie sitting in a shoeshine shop.",
        "Betty bought some butter but the butter was bitter.",
        "How much wood could a would a woodchuck chuck if a woodchuck could chuck wood.",
        "Red leather yellow leather.",
        "Toy boat toy boat toy boat.",
        "Unique New York"
      ],
      index: 1),
  SpeechModel(
      category: 'Articulation',
      sentences: [
        "The big brown bear",
        "Quick, quiet quokkas quiver quickly.",
        "Peter Piper picked a peck of pickled peppers.",
        "Sally saw seven silly sleepy sheep.",
        "The black cat crept cautiously.",
        "Quick brown fox jumps.",
        "Red lorry yellow lorry",
        "She sells sea shell by the seashore.",
        "Six slippery snails slid slowly seaward sliding silently.",
        "The sixth sick sheik sixth sheep's sick."
      ],
      index: 2),
  SpeechModel(
      category: 'Pronunciation',
      sentences: [
        "He's an heir to the throne.",
        "Freshly fried flying fish.",
        "She's a successful actress.",
        "A proper copper coffee pot.",
        "Schedule your Schedule Carefully",
        "Rural juror",
        "THe water is boiling.",
        "She saw Susie in the shoeshine shop.",
        "The sixth sick sheik's sixth sheep's sick.",
        "The wind is blowing."
      ],
      index: 3),
  SpeechModel(
      category: 'Communication',
      sentences: [
        "I understand your perspective.",
        "I value your opinion on this matter",
        "We should engage in open dialogue.",
        "Can you elaborate on your proposal?",
        "Constructive feedback is essential.",
        "Could you clarify your point?",
        "Effective Communication is Key",
        "I appreciate your input",
        "Let's collaborate on this project.",
        "Let's discuss this further."
      ],
      index: 4),
  SpeechModel(
      category: 'Linguistics',
      sentences: [
        "Phonetics studies speech sounds.",
        "Syntax deals with sentence structure.",
        "Morphology analyzes word forms.",
        "Pragmatics studies language in context.",
        "Phonology studies sound patterns.",
        "Morphemes are the units of morphology.",
        "Pragmatics considers language use.",
        "Semantics explores word meanings.",
        "Syntax examines sentence structure.",
        'Semantics delves into meanings.'
      ],
      index: 5),
  SpeechModel(
      category: 'Vocalization',
      sentences: [
        "Harmonize with others in a choir.",
        "Practice your vocal warm ups.",
        "Project your voice for clarity.",
        "Project your voice with confidence.",
        "Resonate with your audience.",
        "Sing scales to improve vocal range.",
        "Singing requires proper vocal technique.",
        "Vocal exercises enhance vocal ability.",
        "Vocalize with proper breath control.",
        "Work on vocal resonance."
      ],
      index: 6),
  SpeechModel(
      category: 'Oration',
      sentences: [
        "Ladies and gentlemen, today I'd like to discuss about Broadcasting",
        "In conclusion, let me summarize my main points.",
        "I want to inspire you with my words.",
        "This speech aims to inform and persuade.",
        "As a public speaker, I strive for impact.",
        "Greetings, esteemed colleagues.",
        "In summary, let's recap the main points.",
        "I aim to motivate and uplift.",
        "This address seeks to inform and sway.",
        "My speeches aspire to leave an impact."
      ],
      index: 7),
  SpeechModel(
      category: 'Expression',
      sentences: [
        "I'm thrilled to be here today.",
        "I feel deeply honored and grateful.",
        "My passion for this topic is evident.",
        "I can't overemphasize the importance of this issue.",
        "Let me convey my enthusiasm for our project.",
        "I'm genuinely excited to be here.",
        "I'm profoundly appreciative of this opportunity.",
        "My fervor for this subject shines through.",
        "The significance of this matter can't be overstated.",
        "Allow me to convey my enthusiasm for our cause."
      ],
      index: 8),
  SpeechModel(
      category: 'Intonation',
      sentences: [
        "Are you sure about that?",
        "I can't believe you did that!",
        "It's a beautiful day, isn't it?",
        "You're coming to the party, right?",
        "I have a question for you.",
        "You really think so?",
        "I can hardly believe it!",
        "It's a beautiful day, don't you think?",
        "You'll be at the gathering, won't you?",
        "I've got a question for you, okay?"
      ],
      index: 9),
  SpeechModel(
      category: 'Consistency',
      sentences: [
        "Consistency is the key to success.",
        "We need to maintain a consistent approach.",
        "Our policies must remain consistent.",
        "Consistency builds trust with our customers.",
        "Inconsistency can lead to confusion.",
        "Steadiness is the pathway to achievement.",
        "We must stick to a uniform strategy.",
        "Our principles should remain unwavering.",
        "Reliability fosters trust among clients.",
        "Inconsistency leads to ambiguity."
      ],
      index: 10),
  SpeechModel(
      category: 'Enunciation',
      sentences: [
        "Clear communication is crucial for success.",
        "Articulate your thoughts with precision and clarity.",
        "Ensure every syllable is enunciated effectively.",
        "The enunciator announced the important news.",
        "Proper enunciation enhances understanding.",
        "Enunciate each word distinctly and confidently.",
        "The speaker's enunciation was impeccable.",
        "Enunciate your words for a powerful impact.",
        "Enunciation is the key to effective communication.",
        "Practicing enunciation improves speech clarity."
      ],
      index: 11)
];
