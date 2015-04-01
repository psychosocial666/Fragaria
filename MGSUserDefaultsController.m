//
//  MGSUserDefaultsController.m
//  Fragaria
//
//  Created by Jim Derry on 3/3/15.
//
//

#import "MGSMutableDictionary.h"
#import "MGSUserDefaultsController.h"
#import "MGSUserDefaultsDefinitions.h"
#import "MGSUserDefaults.h"
#import "MGSFragariaView.h"


#pragma mark - CATEGORY MGSUserDefaultsController

@interface MGSUserDefaultsController ()

@property (nonatomic, strong, readwrite) id values;

@end


#pragma mark - CLASS MGSUserDefaultsController - Implementation


static NSMutableDictionary *controllerInstances;

@implementation MGSUserDefaultsController

@synthesize managedInstances = _managedInstances;
@synthesize persistent = _persistent;


#pragma mark - Class Methods - Singleton Controllers

/*
 *  + sharedControllerForGroupID:
 */
+ (instancetype)sharedControllerForGroupID:(NSString *)groupID
{
    if (!groupID || [groupID length] == 0)
    {
        groupID = MGSUSERDEFAULTS_GLOBAL_ID;
    }

	@synchronized(self) {

        if (!controllerInstances)
        {
            controllerInstances = [[NSMutableDictionary alloc] init];
        }

		if ([[controllerInstances allKeys] containsObject:groupID])
		{
			return [controllerInstances objectForKey:groupID];
		}
	
		MGSUserDefaultsController *newController = [[[self class] alloc] initWithGroupID:groupID];
		[controllerInstances setObject:newController forKey:groupID];
		return newController;
	}
}


/*
 *  + sharedController
 */
+ (instancetype)sharedController
{
	return [[self class] sharedControllerForGroupID:MGSUSERDEFAULTS_GLOBAL_ID];
}


#pragma mark - Property Accessors

/*
 *  @property managedInstances
 */
- (void)setManagedInstances:(NSSet *)managedInstances
{
	NSAssert(![self.groupID isEqualToString:MGSUSERDEFAULTS_GLOBAL_ID],
			 @"You cannot set managedInstances for the global controller.");
	
	[[[self class] sharedController] unregisterBindings];
	[self unregisterBindings];
    _managedInstances = managedInstances;
	[self registerBindings];
	[[[self class] sharedController] registerBindings];
}

- (NSSet *)managedInstances
{
    if ([self.groupID isEqualToString:MGSUSERDEFAULTS_GLOBAL_ID])
    {
        NSMutableSet *allInstances = [[NSMutableSet alloc] init];

        for (MGSUserDefaultsController *controllerInstance in [controllerInstances allValues])
        {
            if (![controllerInstance.groupID isEqualToString:MGSUSERDEFAULTS_GLOBAL_ID])
            {
                [allInstances unionSet:controllerInstance.managedInstances];
            }
        }
        return allInstances;
    }
    else
    {
        return _managedInstances;
    }
}


/*
 *  @property managedProperties
 */
- (void)setManagedProperties:(NSSet *)managedProperties
{
    [self unregisterBindings];
    _managedProperties = managedProperties;
	[self registerBindings];
}


/*
 *  @property persistent
 */
- (void)setPersistent:(BOOL)persistent
{
	if (_persistent == persistent) return;

    _persistent = persistent;

	if (persistent)
	{
        NSDictionary *defaultsDict = [self archiveForDefaultsDictionary:self.values];
        [[NSUserDefaults standardUserDefaults] setObject:defaultsDict forKey:self.groupID];
        
		[[NSUserDefaultsController sharedUserDefaultsController] addObserver:self
																  forKeyPath:[NSString stringWithFormat:@"values.%@", self.groupID]
																	 options:NSKeyValueObservingOptionNew
																	 context:(__bridge void *)(self.groupID)];
	}
	else
	{
		[[NSUserDefaultsController sharedUserDefaultsController] removeObserver:self
                                                                     forKeyPath:[NSString stringWithFormat:@"values.%@", self.groupID]
                                                                        context:(__bridge void *)(self.groupID)];

        NSDictionary *currentDict = [[NSUserDefaults standardUserDefaults] objectForKey:self.groupID];
        NSDictionary *defaultsValues = [self unarchiveFromDefaultsDictionary:currentDict];
        for (NSString *key in self.values)
        {
            if (![[self.values valueForKey:key] isEqualTo:[defaultsValues valueForKey:key]])
            {
                [self.values setValue:[defaultsValues valueForKey:key] forKey:key];
            }
        }
	}
}

- (BOOL)isPersistent
{
	return _persistent;
}


#pragma mark - Initializers (not exposed)

/*
 *  - initWithGroupID:
 */
- (instancetype)initWithGroupID:(NSString *)groupID
{
	if ((self = [super init]))
	{
		_groupID = groupID;

		NSDictionary *defaults = [[MGSUserDefaultsDefinitions class] fragariaDefaultsDictionary];
		
		[[MGSUserDefaults sharedUserDefaultsForGroupID:groupID] registerDefaults:defaults];
        defaults = [[NSUserDefaults standardUserDefaults] valueForKey:groupID];
        self.values = [[MGSMutableDictionary alloc] initWithController:self dictionary:[self unarchiveFromDefaultsDictionary:defaults]];
	}
	
	return self;
}


/*
 *  - init
 *    Just in case someone tries to create their own instance
 *    of this class, we'll make sure it's always "Global".
 */
- (instancetype)init
{
	return [self initWithGroupID:MGSUSERDEFAULTS_GLOBAL_ID];
}


#pragma mark - Binding Registration/Unregistration and KVO Handling


/*
 *  -registerBindings
 */
- (void)registerBindings
{
	// Bind all relevant properties of each instance to `values` dictionary.
    for (NSString *key in self.managedProperties)
    {
        for (MGSFragariaView *fragaria in self.managedInstances)
        {
            [fragaria bind:key toObject:self.values withKeyPath:key options:nil];
        }
    }
}


/*
 *  - unregisterBindings:
 */
- (void)unregisterBindings
{
    // Stop observing properties
    for (NSString *key in self.managedProperties)
    {
        for (MGSFragariaView *fragaria in self.managedInstances)
        {
            [fragaria unbind:key];
        }
    }
}


/*
 * - observeValueForKeyPath:ofObject:change:context:
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	// The only keypath we've registered, but let's check in case we accidentally something.
	if ([[NSString stringWithFormat:@"values.%@", self.groupID] isEqualToString:keyPath])
	{
        NSDictionary *currentDict = [[NSUserDefaults standardUserDefaults] objectForKey:self.groupID];
        NSDictionary *defaultsValues = [self unarchiveFromDefaultsDictionary:currentDict];
        for (NSString *key in defaultsValues)
        {
            // If we use self.value valueForKey: here, we will get the value from defaults.
            if (![[defaultsValues valueForKey:key] isEqualTo:[self.values objectForKey:key]])
            {
                [self.values setValue:[defaultsValues valueForKey:key] forKey:key];
            }
        }
	}
}


#pragma mark - Utilities


/*
 *  - unarchiveFromDefaultsDictionary:
 *    The fragariaDefaultsDictionary is meant to be written to userDefaults as
 *    is, but it's not good for internal storage, where we want real instances,
 *    and not archived data.
 */
- (NSDictionary *)unarchiveFromDefaultsDictionary:(NSDictionary *)source
{
    NSMutableDictionary *destination = [[NSMutableDictionary alloc] initWithCapacity:source.count];
    for (NSString *key in source)
    {
        id object = [source objectForKey:key];
        if ([object isKindOfClass:[NSData class]])
        {
            object = [NSUnarchiver unarchiveObjectWithData:object];
        }
        [destination setObject:object forKey:key];
    }

    return destination;
}


/*
 * - archiveForDefaultsDictionary:
 *   If we're copying things to user defaults, we have to make sure that any
 *   objects the requiring archiving are archived.
 */
- (NSDictionary *)archiveForDefaultsDictionary:(NSDictionary *)source
{
    NSMutableDictionary *destination = [[NSMutableDictionary alloc] initWithCapacity:source.count];
    for (NSString *key in source)
    {
        id object = [source objectForKey:key];
        if ([object isKindOfClass:[NSFont class]] || [object isKindOfClass:[NSColor class]])
        {
            object = [NSArchiver archivedDataWithRootObject:object];
        }

        [destination setObject:object forKey:key];
    }

    return destination;

}


@end
