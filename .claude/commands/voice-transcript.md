CRITICAL: Your entire response must be ONLY a valid JSON object. No text before. No text after. No markdown. No explanation. Just the JSON object starting with { and ending with }.

Below is a transcript of a voicenote. Analyse it and take action:

**Classification:**
1. Personal Note → Clean up, save to `/notes/` with descriptive filename
2. Task Instruction → Execute the task using available tools
3. Conversation → Diarise (Speaker 1, Speaker 2), save to `/meeting-notes/`

**Process:**
1. Save raw transcript to `/transcripts/YYYY-MM-DD-short-description.txt`
2. Process according to classification above
3. Output ONLY the JSON response below

**Transcript:**
{{argument}}

**OUTPUT FORMAT - THIS IS MANDATORY:**
Your complete response must be exactly this JSON object and nothing else:
{"updateTitle":"6 words or less title","content":"Brief summary of actions taken and file paths"}

DO NOT include any text outside the JSON object. DO NOT use markdown code blocks. DO NOT wrap in an array. DO NOT explain what you did. The VoiceHub app parses your raw response as JSON - any extra text will cause a parse error.
