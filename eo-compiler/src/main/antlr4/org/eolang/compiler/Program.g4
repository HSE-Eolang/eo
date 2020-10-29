grammar Program;

@header {
    import java.util.LinkedList;
}

tokens { TAB, UNTAB }

@lexer::members {
    private int currentTabs = 0;
    private LinkedList<Token> tokens = new LinkedList<>();
    @Override
    public Token nextToken() {
        return this.tokens.isEmpty() ? super.nextToken() : this.tokens.poll();
    }
    public void emitToken(int t, int line) {
        CommonToken tkn = new CommonToken(t, "");
        tkn.setLine(line);
        this.tokens.offer(tkn);
    }
}

program
    :
    license?
    metas?
    (object EOL)+
    ;

license
    :
    (COMMENT EOL)+
    EOL
    ;

metas
    :
    (META EOL)+
    EOL
    ;

object
    :
    vobject
    |
    hobject
    ;

vobject
    :
    COMMENT*
    (attributes | NAME)
    suffix?
    EOL
    TAB
    head=object (EOL tail=object)*
    |
    vobject
    EOL
    DOT
    NAME
    ;

attributes
    :
    LSQ
    head=NAME (SPACE tail=NAME)*
    RSQ
    ;

suffix
    :
    SPACE
    ARROW
    SPACE
    NAME
    ;

hobject
    :
    AT
    |
    NAME
    |
    data
    |
    hobject
    DOT
    NAME
    |
    LB
    hobject
    RB
    |
    hobject
    suffix
    |
    head=hobject (SPACE tail=hobject)
    ;

data
    :
    STRING
    |
    INTEGER
    |
    FLOAT
    |
    HEX
    |
    CHAR
    ;

COMMENT: HASH ~[\r\n]*;
META: PLUS NAME (SPACE ~[\r\n]+)?;

ARROW: '>';
PLUS: '+';
SPACE: ' ';
DOT: '.';
LSQ: '[';
RSQ: ']';
LB: '(';
RB: ')';
AT: '@';
HASH: '#';
EOL
    :
    [\r\n]
    SPACE*
    {
        int tabs = getText().replaceAll("[\r\n]+", "").length() / 2;
        if (tabs < this.currentTabs) {
            for (int i = 0; i < this.currentTabs - tabs; ++i) {
                this.emitToken(ProgramParser.UNTAB, getLine() + 1);
            }
        } else if (tabs > this.currentTabs) {
            for (int i = 0; i < tabs - this.currentTabs; ++i) {
                this.emitToken(ProgramParser.TAB, getLine() + 1);
            }
        }
        this.currentTabs = tabs;
    }
    ;

NAME: LETTER (LETTER | DIGIT)*;

CHAR: '\'' () '\'';
STRING: '"' ('\\"' | ~'"')* '"';
INTEGER: (PLUS | '-')? DIGIT+;
FLOAT: (PLUS | '-')? DIGIT+ DOT DIGIT+;
HEX: '0x' DIGIT+;

LETTER: [a-zA-Z];
DIGIT: [0-9];