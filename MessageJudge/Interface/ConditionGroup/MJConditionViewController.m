//
//  MJConditionViewController.m
//  MessageJudge
//
//  Created by GeXiao on 12/06/2017.
//  Copyright © 2017 GeXiao. All rights reserved.
//

#import "MJConditionViewController.h"
#import "MJCondition.h"
#import "GlobalDefine.h"
#import "MJJudgementRule.h"

NSString *const MJTargetSenderCheckTag = @"MJTargetSenderCheckTag";
NSString *const MJTargetContentCheckTag = @"MJTargetContentCheckTag";

NSString *const MJTypeHasPrefixCheckTag = @"MJTypeHasPrefixCheckTag";
NSString *const MJTypeHasSuffixCheckTag = @"MJTypeHasSuffixCheckTag";
NSString *const MJTypeContainsCheckTag = @"MJTypeContainsCheckTag";
NSString *const MJTypeNotContainsCheckTag = @"MJTypeNotContainsCheckTag";
NSString *const MJTypeContainsRegexCheckTag = @"MJTypeContainsRegexCheckTag";

NSString *const MJKeywordTextInputTag = @"MJKeywordTextInputTag";

@interface MJConditionViewController ()

@end

@implementation MJConditionViewController

- (instancetype)initWithCondition:(MJCondition *)condition {
    self = [super init];
    if (self) {
        _condition = condition;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

- (void)initUI {
    XLFormDescriptor *form = [XLFormDescriptor formDescriptorWithTitle:MJLocalize(@"Condition Configuration")];
    
    XLFormSectionDescriptor *targetSection = [XLFormSectionDescriptor formSectionWithTitle:MJLocalize(@"Condition Target")];
    targetSection.footerTitle = MJLocalize(@"Choose message's sender or content as object that attempts to match with.");
    
    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:MJTargetSenderCheckTag rowType:XLFormRowDescriptorTypeBooleanCheck title:MJLocalize(@"Sender")];
    row.value = @(self.condition.conditionTarget == MJConditionTargetSender);
    [targetSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:MJTargetContentCheckTag rowType:XLFormRowDescriptorTypeBooleanCheck title:MJLocalize(@"Content")];
    row.value = @(self.condition.conditionTarget == MJConditionTargetContent);
    [targetSection addFormRow:row];
    [form addFormSection:targetSection];
    
    XLFormSectionDescriptor *typeSection = [XLFormSectionDescriptor formSectionWithTitle:MJLocalize(@"Condition Type")];
    typeSection.footerTitle = MJLocalize(@"Select one match pattern.");
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:MJTypeHasPrefixCheckTag rowType:XLFormRowDescriptorTypeBooleanCheck title:MJLocalize(@"has prefix")];
    row.value = @(self.condition.conditionType == MJConditionTypeHasPrefix);
    [typeSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:MJTypeHasSuffixCheckTag rowType:XLFormRowDescriptorTypeBooleanCheck title:MJLocalize(@"has suffix")];
    row.value = @(self.condition.conditionType == MJConditionTypeHasSuffix);
    [typeSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:MJTypeContainsCheckTag rowType:XLFormRowDescriptorTypeBooleanCheck title:MJLocalize(@"contains")];
    row.value = @(self.condition.conditionType == MJConditionTypeContains);
    [typeSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:MJTypeNotContainsCheckTag rowType:XLFormRowDescriptorTypeBooleanCheck title:MJLocalize(@"doesn't contain")];
    row.value = @(self.condition.conditionType == MJConditionTypeNotContains);
    [typeSection addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:MJTypeContainsRegexCheckTag rowType:XLFormRowDescriptorTypeBooleanCheck title:MJLocalize(@"matches regex")];
    row.value = @(self.condition.conditionType == MJConditionTypeContainsRegex);
    [typeSection addFormRow:row];
    [form addFormSection:typeSection];
    
    XLFormSectionDescriptor *keywordSection = [XLFormSectionDescriptor formSectionWithTitle:MJLocalize(@"Keyword")];
    XLFormRowDescriptor *keywordRow = [XLFormRowDescriptor formRowDescriptorWithTag:MJKeywordTextInputTag rowType:XLFormRowDescriptorTypeText title:nil];
    keywordRow.value = self.condition.keyword;
    [keywordRow.cellConfigAtConfigure setObject:MJLocalize(@"Required") forKey:@"textField.placeholder"];
    keywordRow.required = YES;
    [keywordSection addFormRow:keywordRow];
    [form addFormSection:keywordSection];
    
    self.form = form;
}

- (NSDictionary<NSString *, NSString *> *)targetRowTagsRelation {
    return @{@(MJConditionTargetSender): MJTargetSenderCheckTag,
             @(MJConditionTargetContent): MJTargetContentCheckTag
             };
}

- (NSDictionary<NSString *, NSString *> *)typeRowTagsRelation {
    return @{@(MJConditionTypeHasPrefix): MJTypeHasPrefixCheckTag,
             @(MJConditionTypeHasSuffix): MJTypeHasSuffixCheckTag,
             @(MJConditionTypeContains): MJTypeContainsCheckTag,
             @(MJConditionTypeNotContains): MJTypeNotContainsCheckTag,
             @(MJConditionTypeContainsRegex): MJTypeContainsRegexCheckTag
             };
}

- (void)selectTarget:(MJConditionTarget)target {
    self.condition.conditionTarget = target;
    static NSDictionary<NSString *, NSString *> *relation;
    if (!relation) {
        relation = [self targetRowTagsRelation];
    }
    for (NSString *key in relation) {
        if (key.integerValue != target) {
            XLFormRowDescriptor *row =  [self.form formRowWithTag:relation[key]];
            if ([row.value boolValue]) {
                row.value = @(NO);
                [self reloadFormRow:row];
            }
        }
    }
}

- (void)selectTypeByRowTag:(NSString *)tag {
    static NSDictionary<NSString *, NSString *> *relation;
    if (!relation) {
        relation = [self typeRowTagsRelation];
    }
    for (NSString *key in relation) {
        if ([relation[key] isEqualToString:tag]) {
            self.condition.conditionType = key.integerValue;
        } else {
            XLFormRowDescriptor *row =  [self.form formRowWithTag:relation[key]];
            if ([row.value boolValue]) {
                row.value = @(NO);
                [self reloadFormRow:row];
            }
        }
        
    }
}

- (void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)formRow oldValue:(id)oldValue newValue:(id)newValue {
    NSLog(@"%@ from %@ to %@", formRow.tag, oldValue, newValue);
    if ([formRow.tag isEqualToString:MJTargetSenderCheckTag] && [newValue boolValue]) {
        [self selectTarget:MJConditionTargetSender];
    }
    if ([formRow.tag isEqualToString:MJTargetContentCheckTag] && [newValue boolValue]) {
        [self selectTarget:MJConditionTargetContent];
    }
    if (([formRow.tag isEqualToString:MJTypeHasPrefixCheckTag] || [formRow.tag isEqualToString:MJTypeHasSuffixCheckTag] || [formRow.tag isEqualToString:MJTypeContainsCheckTag] || [formRow.tag isEqualToString:MJTypeNotContainsCheckTag] || [formRow.tag isEqualToString:MJTypeContainsRegexCheckTag]) && [newValue boolValue]) {
        [self selectTypeByRowTag:formRow.tag];
    }
    if ([formRow.tag isEqualToString:MJKeywordTextInputTag]) {
        NSString *newKeyword = formRow.value;
        if (newKeyword.length > 0) {
            self.condition.keyword = newKeyword;
        }
    }
    [MJGlobalRule save];
}


@end