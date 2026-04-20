class NoteTemplate {
  final String id;
  final String name;
  final String icon;
  final String content;

  const NoteTemplate({
    required this.id,
    required this.name,
    required this.icon,
    required this.content,
  });
}

class NoteTemplates {
  static const List<NoteTemplate> templates = [
    NoteTemplate(
      id: 'cornell',
      name: 'Cornell Notes',
      icon: '📋',
      content: '''## Main Topic
---

### Key Points / Cues
- 
- 
- 

### Notes
- 
- 
- 

### Summary
Write a brief summary of the lecture here...
''',
    ),
    NoteTemplate(
      id: 'lecture_summary',
      name: 'Lecture Summary',
      icon: '📚',
      content: '''## Lecture Topic: 
### Date: 

---

### Key Concepts
1. 
2. 
3. 

### Detailed Notes


### Questions to Review
- [ ] 
- [ ] 
- [ ] 

### Action Items
- 
''',
    ),
    NoteTemplate(
      id: 'exam_notes',
      name: 'Exam Notes',
      icon: '📝',
      content: '''## Exam Preparation

### Important Formulas
| Formula | Description |
|---------|-------------|
|         |             |
|         |             |

### Key Definitions
- **Term 1**: 
- **Term 2**: 
- **Term 3**: 

### Important Points
1. 
2. 
3. 

### Practice Questions
- Q: 
  A: 

### Common Mistakes to Avoid
- 
''',
    ),
  ];
}
