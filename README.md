# Games and Math
Inspired by the book Game Programming Patterns on http://gameprogrammingpatterns.com I decided to develop a fast, type safe Game Engine in Swift using an Entity Component System (ECS) Pattern. The code examples in the book were all in C/C++, however, I felt that these patterns would be improved by transferring them into a type safe Swift code.

My root design pattern mainly consists of four elements: Components, Entities, Systems and Games
Components contain custom logics
Entities are defined by Components
Specific Entities are gathered to Systems
Games combine Systems, Entities and Components 
Most types are protocols and structs. Entities are required to be a class, components are not. Therefore a position component is just a type alias of a double2 from simd.

Even though Apple already supports these patterns in their GameplayKit Framework, I decided to start from scratch, as the GameplayKit Framework is written in Objective-C and does not comprise all of Your nice Swift features. Also before, there were dynamic casts required, which is now obsolete in my engine. And lastly, when accessing a component attached to an entity, it would only be discovered during the run time of the Game, if the component was non existent, whereas with the new Engine, a non existing component will be identified already during the compile time. This saves our users a lot of trouble as otherwise the program might crash.

So, by the power of protocols and generic types, dynamic casts can be avoided. Components were designed to optionally require specific subcomponents when assigned to a certain entity using generic type. And the compiler is able to generate specialized components for any entity.
The same principles apply to Systems and Games, too! 
Therefore the resulting Game Engine is type safe and faster in it’s performance 

My Game Engine supports iOS, tvOS and macOS, includes components for SpriteKit Nodes and systems for SpriteKit Scenes. 

During the development of my ECS Game Engine, I compared the time profile of my implementation with the ECS in GameplayKit and got a positive result for my implementation.
It is always at least as fast as the GameplayKit, some times faster. 

While running the time profile, I also realised that using a delegate pattern is no good choice for calling methods on another object as any specialization is lost that way. Therefore I chose callbacks over delegation in most places during my further development of the Game Engine.

Most images and sounds in the attached Game were open source. Others were created by me, for example, all particle effects and some edits on the images, to improve their fit in the Game.