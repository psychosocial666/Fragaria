//
//  MGSFragariaView.h
//  Fragaria
//
//  File created by Jim Derry on 2015/02/07.
//
//  Implements an NSView subclass that abstracts several characteristics of Fragaria,
//  such as the use of Interface Builder to set delegates and assign key-value pairs.
//  Also provides property abstractions for Fragaria's settings and methods.
//

#import "MGSFragariaView.h"
#import "MGSFragariaViewPrivate.h"
#import "MGSFragariaFramework.h"
#import "SMLTextViewPrivate.h"

#import "MGSBreakpointDelegate.h"           // Justification: public delegate.
#import "MGSDragOperationDelegate.h"        // Justification: public delegate.
#import "MGSFragariaTextViewDelegate.h"     // Justification: public delegate.
#import "SMLSyntaxColouringDelegate.h"      // Justification: public delegate.
#import "SMLAutoCompleteDelegate.h"         // Justification: public delegate.

#import "SMLSyntaxError.h"                  // Justification: external users require it.
#import "SMLTextView.h"                     // Justification: external users require it.


#pragma mark - IMPLEMENTATION


@implementation MGSFragariaView

/* Synthesis required in order to implement protocol declarations. */
@synthesize gutterView = _gutterView;
@synthesize scrollView = _scrollView;
@synthesize textView = _textView;
 

#pragma mark - Initialization and Setup


/*
 * - initWithCoder:
 *   Called when unarchived from a nib.
 */
- (instancetype)initWithCoder:(NSCoder *)coder
{
	if ((self = [super initWithCoder:coder]))
	{
		/*
		   Don't initialize in awakeFromNib otherwise IB User
		   Define Runtime Attributes won't be honored.
		 */
		[self setupView];
	}
	return self;
}


/*
 * - initWithFrame:
 *   Called when used in a framework.
 */
- (instancetype)initWithFrame:(NSRect)frameRect
{
    if ((self = [super initWithFrame:frameRect]))
    {
		/*
		   Don't initialize in awakeFromNib otherwise IB User
		   Define Runtime Attributes won't be honored.
		 */
		[self setupView];
    }
    return self;
}


/*
 * When using propagateValue:forBinding we can help ensure type safety by using
 * NSStringFromSelector(@selector(string))] instead of passing a string.
 */


#pragma mark - Accessing Fragaria's Views
/*
 * @property syntaxColouring
 */
- (SMLSyntaxColouring *)syntaxColouring
{
	return self.textView.syntaxColouring;
}


#pragma mark - Accessing Text Content


/*
 * @property string
 */
- (void)setString:(NSString *)string
{
	self.textView.string = string;
    [self propagateValue:string forBinding:NSStringFromSelector(@selector(string))];
}

- (NSString *)string
{
	return self.textView.string;
}


/*
 * @property attributedStringWithTemporaryAttributesApplied
 */
- (NSAttributedString *)attributedStringWithTemporaryAttributesApplied
{
    return self.textView.attributedStringWithTemporaryAttributesApplied;
}


#pragma mark - Creating Split Panels


/*
 * - replaceTextStorage:
 */
- (void)replaceTextStorage:(NSTextStorage *)textStorage
{
    NSRange wholeRange = NSMakeRange(0, textStorage.length);
    
    [self.gutterView layoutManagerWillChangeTextStorage];
    [self.syntaxErrorController layoutManagerWillChangeTextStorage];
    [self.textView.syntaxColouring layoutManagerWillChangeTextStorage];
    
    [textStorage addAttributes:self.textView.typingAttributes range:wholeRange];
    [self.textView.layoutManager replaceTextStorage:textStorage];
    
    [self.gutterView layoutManagerDidChangeTextStorage];
    [self.syntaxErrorController layoutManagerDidChangeTextStorage];
    [self.textView.syntaxColouring layoutManagerDidChangeTextStorage];
}


#pragma mark - Configuring Syntax Highlighting


/*
 * @property syntaxColoured
 */
- (void)setSyntaxColoured:(BOOL)syntaxColoured
{
	self.textView.syntaxColoured = syntaxColoured;
	[self propagateValue:@(syntaxColoured) forBinding:NSStringFromSelector(@selector(isSyntaxColoured))];
}

- (BOOL)isSyntaxColoured
{
	return self.textView.isSyntaxColoured;
}


/*
 * @property syntaxDefinitionName
 */
- (void)setSyntaxDefinitionName:(NSString *)syntaxDefinitionName
{
	self.textView.syntaxColouring.syntaxDefinitionName = syntaxDefinitionName;
	[self propagateValue:syntaxDefinitionName forBinding:NSStringFromSelector(@selector(syntaxDefinitionName))];
}

- (NSString *)syntaxDefinitionName
{
	return self.textView.syntaxColouring.syntaxDefinitionName;
}


/*
 * @property syntaxColouringDelegate
 */
- (void)setSyntaxColouringDelegate:(id<SMLSyntaxColouringDelegate>)syntaxColouringDelegate
{
    self.textView.syntaxColouring.syntaxColouringDelegate = syntaxColouringDelegate;
}

- (id<SMLSyntaxColouringDelegate>)syntaxColoringDelegate
{
    return self.textView.syntaxColouring.syntaxColouringDelegate;
}


/*
 * @property BOOL coloursMultiLineStrings
 */
- (void)setColoursMultiLineStrings:(BOOL)coloursMultiLineStrings
{
    self.textView.syntaxColouring.coloursMultiLineStrings = coloursMultiLineStrings;
	[self propagateValue:@(coloursMultiLineStrings) forBinding:NSStringFromSelector(@selector(coloursMultiLineStrings))];
}

- (BOOL)coloursMultiLineStrings
{
    return self.textView.syntaxColouring.coloursMultiLineStrings;
}


/*
 * @property BOOL coloursOnlyUntilEndOfLine
 */
- (void)setColoursOnlyUntilEndOfLine:(BOOL)coloursOnlyUntilEndOfLine
{
    self.textView.syntaxColouring.coloursOnlyUntilEndOfLine = coloursOnlyUntilEndOfLine;
	[self propagateValue:@(coloursOnlyUntilEndOfLine) forBinding:NSStringFromSelector(@selector(coloursOnlyUntilEndOfLine))];
}

- (BOOL)coloursOnlyUntilEndOfLine
{
    return self.textView.syntaxColouring.coloursOnlyUntilEndOfLine;
}


#pragma mark - Configuring Autocompletion


/*
 * @property autoCompleteDelegate
 */
- (void)setAutoCompleteDelegate:(id<SMLAutoCompleteDelegate>)autoCompleteDelegate
{
    self.textView.autoCompleteDelegate = autoCompleteDelegate;
}

- (id<SMLAutoCompleteDelegate>)autoCompleteDelegate
{
    return self.textView.autoCompleteDelegate;
}


/*
 * @property double autoCompleteDelay
 */
- (void)setAutoCompleteDelay:(double)autoCompleteDelay
{
    self.textView.autoCompleteDelay = autoCompleteDelay;
	[self propagateValue:@(autoCompleteDelay) forBinding:NSStringFromSelector(@selector(autoCompleteDelay))];
}

- (double)autoCompleteDelay
{
    return self.textView.autoCompleteDelay;
}

 
/*
 * @property BOOL autoCompleteEnabled
 */
- (void)setAutoCompleteEnabled:(BOOL)autoCompleteEnabled
{
    self.textView.autoCompleteEnabled = autoCompleteEnabled;
	[self propagateValue:@(autoCompleteEnabled) forBinding:NSStringFromSelector(@selector(autoCompleteEnabled))];
}

- (BOOL)autoCompleteEnabled
{
    return self.textView.autoCompleteEnabled;
}

 
/*
 * @property BOOL autoCompleteWithKeywords
 */
- (void)setAutoCompleteWithKeywords:(BOOL)autoCompleteWithKeywords
{
    self.textView.autoCompleteWithKeywords = autoCompleteWithKeywords;
	[self propagateValue:@(autoCompleteWithKeywords) forBinding:NSStringFromSelector(@selector(autoCompleteWithKeywords))];
}

- (BOOL)autoCompleteWithKeywords
{
    return self.textView.autoCompleteWithKeywords;
}


#pragma mark - Highlighting the current line


/*
 * @property currentLineHighlightColour
 */
- (void)setCurrentLineHighlightColour:(NSColor *)currentLineHighlightColour
{
    self.textView.currentLineHighlightColour = currentLineHighlightColour;
	[self propagateValue:currentLineHighlightColour forBinding:NSStringFromSelector(@selector(currentLineHighlightColour))];
}

- (NSColor *)currentLineHighlightColour
{
    return self.textView.currentLineHighlightColour;
}


/*
 * @property highlightsCurrentLine
 */
- (void)setHighlightsCurrentLine:(BOOL)highlightsCurrentLine
{
    self.textView.highlightsCurrentLine = highlightsCurrentLine;
	[self propagateValue:@(highlightsCurrentLine) forBinding:NSStringFromSelector(@selector(highlightsCurrentLine))];
}

- (BOOL)highlightsCurrentLine
{
    return self.textView.highlightsCurrentLine;
}


#pragma mark - Configuring the Gutter


/*
 * @property showsGutter
 */
- (void)setShowsGutter:(BOOL)showsGutter
{
	self.scrollView.rulersVisible = showsGutter;
	[self propagateValue:@(showsGutter) forBinding:NSStringFromSelector(@selector(showsGutter))];
}

- (BOOL)showsGutter
{
	return self.scrollView.rulersVisible;
}


/*
 * @property minimumGutterWidth
 */
- (void)setMinimumGutterWidth:(CGFloat)minimumGutterWidth
{
	self.gutterView.minimumWidth = minimumGutterWidth;
	[self propagateValue:@(minimumGutterWidth) forBinding:NSStringFromSelector(@selector(minimumGutterWidth))];
}

- (CGFloat)minimumGutterWidth
{
	return self.gutterView.minimumWidth;
}


/*
 * @property showsLineNumbers
 */
- (void)setShowsLineNumbers:(BOOL)showsLineNumbers
{
	self.gutterView.showsLineNumbers = showsLineNumbers;
	[self propagateValue:@(showsLineNumbers) forBinding:NSStringFromSelector(@selector(showsLineNumbers))];
}

- (BOOL)showsLineNumbers
{
	return self.gutterView.showsLineNumbers;
}


/*
 * @property startingLineNumber
 */
- (void)setStartingLineNumber:(NSUInteger)startingLineNumber
{
	[self.gutterView setStartingLineNumber:startingLineNumber];
	[self propagateValue:@(startingLineNumber) forBinding:NSStringFromSelector(@selector(startingLineNumber))];
}

- (NSUInteger)startingLineNumber
{
	return [self.gutterView startingLineNumber];
}


/*
 * @property gutterFont
 */
- (void)setGutterFont:(NSFont *)gutterFont
{
    [self.gutterView setFont:gutterFont];
	[self propagateValue:gutterFont forBinding:NSStringFromSelector(@selector(gutterFont))];
}

- (NSFont *)gutterFont
{
    return self.gutterView.font;
}

/*
 * @property gutterTextColour
 */
- (void)setGutterTextColour:(NSColor *)gutterTextColour
{
    self.gutterView.textColor = gutterTextColour;
	[self propagateValue:gutterTextColour forBinding:NSStringFromSelector(@selector(gutterTextColour))];
}

- (NSColor *)gutterTextColour
{
    return self.gutterView.textColor;
}


#pragma mark - Showing Syntax Errors


/*
 * @property syntaxErrors
 */
- (void)setSyntaxErrors:(NSArray *)syntaxErrors
{
	self.syntaxErrorController.syntaxErrors = syntaxErrors;
}

- (NSArray *)syntaxErrors
{
	return self.syntaxErrorController.syntaxErrors;
}


/*
 * @property showsSyntaxErrors
 */
- (void)setShowsSyntaxErrors:(BOOL)showsSyntaxErrors
{
	self.syntaxErrorController.showsSyntaxErrors = showsSyntaxErrors;
	[self propagateValue:@(showsSyntaxErrors) forBinding:NSStringFromSelector(@selector(showsSyntaxErrors))];
}

- (BOOL)showsSyntaxErrors
{
	return self.syntaxErrorController.showsSyntaxErrors;
}


/*
 * @propertyShowsIndividualErrors
 */
- (void)setShowsIndividualErrors:(BOOL)showsIndividualErrors
{
	self.syntaxErrorController.showsIndividualErrors = showsIndividualErrors;
	[self propagateValue:@(showsIndividualErrors) forBinding:NSStringFromSelector(@selector(showsIndividualErrors))];
}

- (BOOL)showsIndividualErrors
{
	return self.syntaxErrorController.showsIndividualErrors;
}


/*
 * @property defaultSyntaxErrorHighlightingColour
 */
- (void)setDefaultSyntaxErrorHighlightingColour:(NSColor *)defaultSyntaxErrorHighlightingColour
{
    self.syntaxErrorController.defaultSyntaxErrorHighlightingColour = defaultSyntaxErrorHighlightingColour;
    [self propagateValue:defaultSyntaxErrorHighlightingColour forBinding:NSStringFromSelector(@selector(defaultSyntaxErrorHighlightingColour))];
}

-(NSColor *)defaultSyntaxErrorHighlightingColour
{
    return self.syntaxErrorController.defaultSyntaxErrorHighlightingColour;
}


#pragma mark - Showing Breakpoints


/*
 * @property breakpointDelegate
 */
- (void)setBreakpointDelegate:(id<MGSBreakpointDelegate>)breakpointDelegate
{
	self.gutterView.breakpointDelegate = breakpointDelegate;
}

- (id<MGSBreakpointDelegate>)breakPointDelegate
{
	return self.gutterView.breakpointDelegate;
}


#pragma mark - Tabulation and Indentation


/*
 * @property tabWidth
 */
- (void)setTabWidth:(NSInteger)tabWidth
{
    self.textView.tabWidth = tabWidth;
	[self propagateValue:@(tabWidth) forBinding:NSStringFromSelector(@selector(tabWidth))];
}

- (NSInteger)tabWidth
{
    return self.textView.tabWidth;
}


/*
 * @property indentWidth
 */
- (void)setIndentWidth:(NSUInteger)indentWidth
{
    self.textView.indentWidth = indentWidth;
	[self propagateValue:@(indentWidth) forBinding:NSStringFromSelector(@selector(indentWidth))];
}

- (NSUInteger)indentWidth
{
    return self.textView.indentWidth;
}


/*
 * @property indentWithSpaces
 */
- (void)setIndentWithSpaces:(BOOL)indentWithSpaces
{
    self.textView.indentWithSpaces = indentWithSpaces;
	[self propagateValue:@(indentWithSpaces) forBinding:NSStringFromSelector(@selector(indentWithSpaces))];
}

- (BOOL)indentWithSpaces
{
    return self.textView.indentWithSpaces;
}


/*
 * @property useTabStops
 */
- (void)setUseTabStops:(BOOL)useTabStops
{
    self.textView.useTabStops = useTabStops;
	[self propagateValue:@(useTabStops) forBinding:NSStringFromSelector(@selector(useTabStops))];
}

- (BOOL)useTabStops
{
    return self.textView.useTabStops;
}


/*
 * @property indentBracesAutomatically
 */
- (void)setIndentBracesAutomatically:(BOOL)indentBracesAutomatically
{
    self.textView.indentBracesAutomatically = indentBracesAutomatically;
	[self propagateValue:@(indentBracesAutomatically) forBinding:NSStringFromSelector(@selector(indentBracesAutomatically))];
}

- (BOOL)indentBracesAutomatically
{
    return self.textView.indentBracesAutomatically;
}


/*
 * @property indentNewLinesAutomatically
 */
- (void)setIndentNewLinesAutomatically:(BOOL)indentNewLinesAutomatically
{
    self.textView.indentNewLinesAutomatically = indentNewLinesAutomatically;
	[self propagateValue:@(indentNewLinesAutomatically) forBinding:NSStringFromSelector(@selector(indentNewLinesAutomatically))];
}

- (BOOL)indentNewLinesAutomatically
{
    return self.textView.indentNewLinesAutomatically;
}


#pragma mark - Automatic Bracing


/*
 * @property insertClosingParenthesisAutomatically
 */
- (void)setInsertClosingParenthesisAutomatically:(BOOL)insertClosingParenthesisAutomatically
{
    self.textView.insertClosingParenthesisAutomatically = insertClosingParenthesisAutomatically;
	[self propagateValue:@(insertClosingParenthesisAutomatically) forBinding:NSStringFromSelector(@selector(insertClosingParenthesisAutomatically))];
}

- (BOOL)insertClosingParenthesisAutomatically
{
    return self.textView.insertClosingParenthesisAutomatically;
}


/*
 * @property insertClosingBraceAutomatically
 */
- (void)setInsertClosingBraceAutomatically:(BOOL)insertClosingBraceAutomatically
{
    self.textView.insertClosingBraceAutomatically = insertClosingBraceAutomatically;
	[self propagateValue:@(insertClosingBraceAutomatically) forBinding:NSStringFromSelector(@selector(insertClosingBraceAutomatically))];
}

- (BOOL)insertClosingBraceAutomatically
{
    return self.textView.insertClosingBraceAutomatically;
}


/*
 * @property showsMatchingBraces
 */
- (void)setShowsMatchingBraces:(BOOL)showsMatchingBraces
{
    self.textView.showsMatchingBraces = showsMatchingBraces;
	[self propagateValue:@(showsMatchingBraces) forBinding:NSStringFromSelector(@selector(showsMatchingBraces))];
}

- (BOOL)showsMatchingBraces
{
    return self.textView.showsMatchingBraces;
}


#pragma mark - Page Guide and Line Wrap


/*
 * @property pageGuideColumn
 */
- (void)setPageGuideColumn:(NSInteger)pageGuideColumn
{
    self.textView.pageGuideColumn = pageGuideColumn;
	[self propagateValue:@(pageGuideColumn) forBinding:NSStringFromSelector(@selector(pageGuideColumn))];
}

- (NSInteger)pageGuideColumn
{
    return self.textView.pageGuideColumn;
}


/*
 * @property showsPageGuide
 */
-(void)setShowsPageGuide:(BOOL)showsPageGuide
{
    self.textView.showsPageGuide = showsPageGuide;
	[self propagateValue:@(showsPageGuide) forBinding:NSStringFromSelector(@selector(showsPageGuide))];
}

- (BOOL)showsPageGuide
{
    return self.textView.showsPageGuide;
}


/*
 * @property lineWrap
 */
- (void)setLineWrap:(BOOL)lineWrap
{
	self.textView.lineWrap = lineWrap;
	[self propagateValue:@(lineWrap) forBinding:NSStringFromSelector(@selector(lineWrap))];
}

- (BOOL)lineWrap
{
	return self.textView.lineWrap;
}


/*
 * @property lineWrapsAtPageGuide
 */
- (void)setLineWrapsAtPageGuide:(BOOL)lineWrapsAtPageGuide
{
    self.textView.lineWrapsAtPageGuide = lineWrapsAtPageGuide;
    [self propagateValue:@(lineWrapsAtPageGuide) forBinding:NSStringFromSelector(@selector(lineWrapsAtPageGuide))];
}

- (BOOL)lineWrapsAtPageGuide
{
    return self.textView.lineWrapsAtPageGuide;
}

#pragma mark - Showing Invisible Characters


/*
 * @property showsInvisibleCharacters
 */
- (void)setShowsInvisibleCharacters:(BOOL)showsInvisibleCharacters
{
    self.textView.showsInvisibleCharacters = showsInvisibleCharacters;
	[self propagateValue:@(showsInvisibleCharacters) forBinding:NSStringFromSelector(@selector(showsInvisibleCharacters))];
}

- (BOOL)showsInvisibleCharacters
{
    return self.textView.showsInvisibleCharacters;
}


/*
 * @property textInvisibleCharactersColour
 */
- (void)setTextInvisibleCharactersColour:(NSColor *)textInvisibleCharactersColour
{
	self.textView.textInvisibleCharactersColour = textInvisibleCharactersColour;
	[self propagateValue:textInvisibleCharactersColour forBinding:NSStringFromSelector(@selector(textInvisibleCharactersColour))];
}

- (NSColor *)textInvisibleCharactersColour
{
	return self.textView.textInvisibleCharactersColour;
}


#pragma mark - Configuring Text Appearance


/*
 * @property textColor
 */
- (void)setTextColor:(NSColor *)textColor
{
    self.textView.textColor = textColor;
	[self propagateValue:textColor forBinding:NSStringFromSelector(@selector(textColor))];
}

- (NSColor *)textColor
{
    return self.textView.textColor;
}


/*
 * @property backgroundColor
 */
- (void)setBackgroundColor:(NSColor *)backgroundColor
{
    self.textView.backgroundColor = backgroundColor;
	[self propagateValue:backgroundColor forBinding:NSStringFromSelector(@selector(backgroundColor))];
}

- (NSColor *)backgroundColor
{
    return self.textView.backgroundColor;
}


/*
 * @property textFont
 */
- (void)setTextFont:(NSFont *)textFont
{
	self.textView.textFont = textFont;
	[self propagateValue:textFont forBinding:NSStringFromSelector(@selector(textFont))];
}

- (NSFont *)textFont
{
	return self.textView.textFont;
}


/*
 * @property lineHeightMultiple
 */
- (void)setLineHeightMultiple:(CGFloat)lineHeightMultiple
{
    self.textView.lineHeightMultiple = lineHeightMultiple;
    [self propagateValue:@(lineHeightMultiple) forBinding:NSStringFromSelector(@selector(lineHeightMultiple))];
}

- (CGFloat)lineHeightMultiple
{
    return self.textView.lineHeightMultiple;
}


#pragma mark - Configuring Additional Text View Behavior


/*
 * @property textViewDelegate
 */
- (void)setTextViewDelegate:(id<MGSFragariaTextViewDelegate, MGSDragOperationDelegate>)textViewDelegate
{
	self.textView.delegate = textViewDelegate;
}

- (id<MGSFragariaTextViewDelegate, MGSDragOperationDelegate>)textViewDelegate
{
	return self.textView.delegate;
}


/*
 * @property hasVerticalScroller
 */
- (void)setHasVerticalScroller:(BOOL)hasVerticalScroller
{
	self.scrollView.hasVerticalScroller = hasVerticalScroller;
	[self propagateValue:@(hasVerticalScroller) forBinding:NSStringFromSelector(@selector(hasVerticalScroller))];
}

- (BOOL)hasVerticalScroller
{
	return self.scrollView.hasVerticalScroller;
}


/*
 * @property insertionPointColor
 */
- (void)setInsertionPointColor:(NSColor *)insertionPointColor
{
    self.textView.insertionPointColor = insertionPointColor;
	[self propagateValue:insertionPointColor forBinding:NSStringFromSelector(@selector(insertionPointColor))];
}

- (NSColor *)insertionPointColor
{
    return self.textView.insertionPointColor;
}


/*
 * @property scrollElasticityDisabled
 */
- (void)setScrollElasticityDisabled:(BOOL)scrollElasticityDisabled
{
	NSScrollElasticity setting = scrollElasticityDisabled ? NSScrollElasticityNone : NSScrollElasticityAutomatic;
	self.scrollView.verticalScrollElasticity = setting;
	[self propagateValue:@(scrollElasticityDisabled) forBinding:NSStringFromSelector(@selector(scrollElasticityDisabled))];
}

- (BOOL)scrollElasticityDisabled
{
	return (self.scrollView.verticalScrollElasticity == NSScrollElasticityNone);
}


/*
 * - goToLine:centered:highlight
 */
- (void)goToLine:(NSInteger)lineToGoTo centered:(BOOL)centered highlight:(BOOL)highlight
{
	if (centered)
		NSLog(@"Warning: centered option is ignored.");
	[self.textView performGoToLine:lineToGoTo setSelected:highlight];
}


#pragma mark - Syntax Highlighting Colours


/*
 * @property colourForAutocomplete
 */
- (void)setColourForAutocomplete:(NSColor *)colourForAutocomplete
{
    self.textView.syntaxColouring.colourForAutocomplete = colourForAutocomplete;
	[self propagateValue:colourForAutocomplete forBinding:NSStringFromSelector(@selector(colourForAutocomplete))];
}

- (NSColor *)colourForAutocomplete
{
    return self.textView.syntaxColouring.colourForAutocomplete;
}


/*
 * @property colourForAttributes
 */
- (void)setColourForAttributes:(NSColor *)colourForAttributes
{
    self.textView.syntaxColouring.colourForAttributes = colourForAttributes;
	[self propagateValue:colourForAttributes forBinding:NSStringFromSelector(@selector(colourForAttributes))];
}

- (NSColor *)colourForAttributes
{
    return self.textView.syntaxColouring.colourForAttributes;
}


/*
 * @property colourForCommands
 */
- (void)setColourForCommands:(NSColor *)colourForCommands
{
    self.textView.syntaxColouring.colourForCommands = colourForCommands;
	[self propagateValue:colourForCommands forBinding:NSStringFromSelector(@selector(colourForCommands))];
}

- (NSColor *)colourForCommands
{
    return self.textView.syntaxColouring.colourForCommands;
}


/*
 * @property colourForComments
 */
- (void)setColourForComments:(NSColor *)colourForComments
{
    self.textView.syntaxColouring.colourForComments = colourForComments;
	[self propagateValue:colourForComments forBinding:NSStringFromSelector(@selector(colourForComments))];
}

- (NSColor *)colourForComments
{
    return self.textView.syntaxColouring.colourForComments;
}


/*
 * @property colourForInstructions
 */
- (void)setColourForInstructions:(NSColor *)colourForInstructions
{
    self.textView.syntaxColouring.colourForInstructions = colourForInstructions;
	[self propagateValue:colourForInstructions forBinding:NSStringFromSelector(@selector(colourForInstructions))];
}

- (NSColor *)colourForInstructions
{
    return self.textView.syntaxColouring.colourForInstructions;
}


/*
 * @property colourForKeywords
 */
- (void)setColourForKeywords:(NSColor *)colourForKeywords
{
    self.textView.syntaxColouring.colourForKeywords = colourForKeywords;
	[self propagateValue:colourForKeywords forBinding:NSStringFromSelector(@selector(colourForKeywords))];
}

- (NSColor *)colourForKeywords
{
    return self.textView.syntaxColouring.colourForKeywords;
}


/*
 * @property colourForNumbers
 */
- (void)setColourForNumbers:(NSColor *)colourForNumbers
{
    self.textView.syntaxColouring.colourForNumbers = colourForNumbers;
	[self propagateValue:colourForNumbers forBinding:NSStringFromSelector(@selector(colourForNumbers))];
}

- (NSColor *)colourForNumbers
{
    return self.textView.syntaxColouring.colourForNumbers;
}


/*
 * @property colourForStrings
 */
- (void)setColourForStrings:(NSColor *)colourForStrings
{
    self.textView.syntaxColouring.colourForStrings = colourForStrings;
	[self propagateValue:colourForStrings forBinding:NSStringFromSelector(@selector(colourForStrings))];
}

- (NSColor *)colourForStrings
{
    return self.textView.syntaxColouring.colourForStrings;
}


/*
 * @property colourForVariables
 */
- (void)setColourForVariables:(NSColor *)colourForVariables
{
    self.textView.syntaxColouring.colourForVariables = colourForVariables;
	[self propagateValue:colourForVariables forBinding:NSStringFromSelector(@selector(colourForVariables))];
}

- (NSColor *)colourForVariables
{
    return self.textView.syntaxColouring.colourForVariables;
}


#pragma mark - Syntax Highlighter Colouring Options


/*
 * @property coloursAttributes
 */
- (void)setColoursAttributes:(BOOL)coloursAttributes
{
    self.textView.syntaxColouring.coloursAttributes = coloursAttributes;
	[self propagateValue:@(coloursAttributes) forBinding:NSStringFromSelector(@selector(coloursAttributes))];
}

- (BOOL)coloursAttributes
{
    return self.textView.syntaxColouring.coloursAttributes;
}

/*
 * @property coloursAutocomplete
 */
- (void)setColoursAutocomplete:(BOOL)coloursAutocomplete
{
    self.textView.syntaxColouring.coloursAutocomplete = coloursAutocomplete;
	[self propagateValue:@(coloursAutocomplete) forBinding:NSStringFromSelector(@selector(coloursAutocomplete))];
}

- (BOOL)coloursAutocomplete
{
    return self.textView.syntaxColouring.coloursAutocomplete;
}


/*
 * @property coloursCommands
 */
- (void)setColoursCommands:(BOOL)coloursCommands
{
    self.textView.syntaxColouring.coloursCommands = coloursCommands;
	[self propagateValue:@(coloursCommands) forBinding:NSStringFromSelector(@selector(coloursCommands))];
}

- (BOOL)coloursCommands
{
    return self.textView.syntaxColouring.coloursCommands;
}


/*
 * @property coloursComments
 */
- (void)setColoursComments:(BOOL)coloursComments
{
    self.textView.syntaxColouring.coloursComments = coloursComments;
	[self propagateValue:@(coloursComments) forBinding:NSStringFromSelector(@selector(coloursComments))];
}

- (BOOL)coloursComments
{
    return self.textView.syntaxColouring.coloursComments;
}


/*
 * @property coloursInstructions
 */
- (void)setColoursInstructions:(BOOL)coloursInstructions
{
    self.textView.syntaxColouring.coloursInstructions = coloursInstructions;
	[self propagateValue:@(coloursInstructions) forBinding:NSStringFromSelector(@selector(coloursInstructions))];
}

- (BOOL)coloursInstructions
{
    return self.textView.syntaxColouring.coloursInstructions;
}


/*
 * @property coloursKeywords
 */
- (void)setColoursKeywords:(BOOL)coloursKeywords
{
    self.textView.syntaxColouring.coloursKeywords = coloursKeywords;
	[self propagateValue:@(coloursKeywords) forBinding:NSStringFromSelector(@selector(coloursKeywords))];
}

- (BOOL)coloursKeywords
{
    return self.textView.syntaxColouring.coloursKeywords;
}


/*
 * @property coloursNumbers
 */
- (void)setColoursNumbers:(BOOL)coloursNumbers
{
    self.textView.syntaxColouring.coloursNumbers = coloursNumbers;
	[self propagateValue:@(coloursNumbers) forBinding:NSStringFromSelector(@selector(coloursNumbers))];
}

- (BOOL)coloursNumbers
{
    return self.textView.syntaxColouring.coloursNumbers;
}


/*
 * @property coloursStrings
 */
- (void)setColoursStrings:(BOOL)coloursStrings
{
    self.textView.syntaxColouring.coloursStrings = coloursStrings;
	[self propagateValue:@(coloursStrings) forBinding:NSStringFromSelector(@selector(coloursStrings))];
}

- (BOOL)coloursStrings
{
    return self.textView.syntaxColouring.coloursStrings;
}


/*
 * @property coloursVariables
*/
- (void)setColoursVariables:(BOOL)coloursVariables
{
    self.textView.syntaxColouring.coloursVariables = coloursVariables;
	[self propagateValue:@(coloursVariables) forBinding:NSStringFromSelector(@selector(coloursVariables))];
}

- (BOOL)coloursVariables
{
    return self.textView.syntaxColouring.coloursVariables;
}


#pragma mark - KVO/KVC/BINDING Handling


/*
 * - propagateValue:forBinding
 *   courtesy of Tom Dalling.
 */
-(void)propagateValue:(id)value forBinding:(NSString*)binding;
{
    NSParameterAssert(binding != nil);

    // WARNING: bindingInfo contains NSNull, so it must be accounted for
    NSDictionary* bindingInfo = [self infoForBinding:binding];
    if (!bindingInfo)
    {
        return; //there is no binding
    }

    // Apply the value transformer, if one has been set
    NSDictionary* bindingOptions = [bindingInfo objectForKey:NSOptionsKey];

    if (bindingOptions)
    {
        NSValueTransformer* transformer = [bindingOptions valueForKey:NSValueTransformerBindingOption];

        if (!transformer || (id)transformer == [NSNull null])
        {
            NSString* transformerName = [bindingOptions valueForKey:NSValueTransformerNameBindingOption];

            if(transformerName && (id)transformerName != [NSNull null])
            {
                transformer = [NSValueTransformer valueTransformerForName:transformerName];
            }
        }

        if (transformer && (id)transformer != [NSNull null])
        {
            if([[transformer class] allowsReverseTransformation])
            {
                value = [transformer reverseTransformedValue:value];
            }
            else
            {
                NSLog(@"WARNING: binding \"%@\" has value transformer, but it doesn't allow reverse transformations in %s", binding, __PRETTY_FUNCTION__);
            }
        }
    }

    id boundObject = [bindingInfo objectForKey:NSObservedObjectKey];

    if (!boundObject || boundObject == [NSNull null])
    {
        NSLog(@"ERROR: NSObservedObjectKey was nil for binding \"%@\" in %s", binding, __PRETTY_FUNCTION__);
        return;
    }

    NSString* boundKeyPath = [bindingInfo objectForKey:NSObservedKeyPathKey];

    if (!boundKeyPath || (id)boundKeyPath == [NSNull null])
    {
        NSLog(@"ERROR: NSObservedKeyPathKey was nil for binding \"%@\" in %s", binding, __PRETTY_FUNCTION__);
        return;
    }

    [boundObject setValue:value forKeyPath:boundKeyPath];
}


#pragma mark - Private/Other/Support

/*
 * - setupView:
 */
- (void)setupView
{
	// create text scrollview
	_scrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, [self bounds].size.width, [self bounds].size.height)];
	NSSize contentSize = [self.scrollView contentSize];
	[self.scrollView setBorderType:NSNoBorder];
	
	[self.scrollView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
	[[self.scrollView contentView] setAutoresizesSubviews:YES];
	[self.scrollView setPostsFrameChangedNotifications:YES];
	self.hasVerticalScroller = YES;
	
	// create textview
	_textView = [[SMLTextView alloc] initWithFrame:NSMakeRect(0, 0, contentSize.width, contentSize.height)];
	[self.scrollView setDocumentView:self.textView];
	
	// create line numbers
	_gutterView = [[MGSLineNumberView alloc] initWithScrollView:self.scrollView fragaria:self];
	[self.scrollView setVerticalRulerView:self.gutterView];
	[self.scrollView setHasVerticalRuler:YES];
	[self.scrollView setHasHorizontalRuler:NO];
	
	// syntaxColouring defaults
	self.textView.syntaxColouring.syntaxDefinitionName = [MGSSyntaxController standardSyntaxDefinitionName];
	self.textView.syntaxColouring.fragaria = self;
	
	// add scroll view to content view
	[self addSubview:self.scrollView];
	
	// update the gutter view
	self.showsGutter = YES;
	
	_syntaxErrorController = [[MGSSyntaxErrorController alloc] init];
	self.syntaxErrorController.lineNumberView = self.gutterView;
	self.syntaxErrorController.textView = self.textView;
	[self setShowsSyntaxErrors:YES];
	
	[self setAutoCompleteDelegate:nil];
}


@end
