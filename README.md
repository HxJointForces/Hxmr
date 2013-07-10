About
====

Hxmr is macro-based MXML replacement for Haxe. It allows you to code object model in declarative style using XML.
Most common use case is UI markup. 

Profit
====
- Declarative style
- Almost full Flex4 MXML specification support
- Bindings
- Cross-platform
- Fully compile-time with checks
- No need to use Apache Flex, could be used for any kind of tasks, even not for UI.
- Fast compilation
- Extensions support

Example
====
```mxml
<?xml version="1.0" encoding="utf-8" ?>
<h:Box xmlns:h="h2d.comp.*" layout="Vertical" xmlns:view="*">
	<h:inlineCss>
		<![CDATA['
		.redBtn {border : 1px solid red;} 
		.redBtn:hover {border : 1px solid #990000;}
		.lbl {font-size:26px;}
		']]>
	</h:inlineCss>
	
	<h:Label text="'Hello, world!'" classes="['lbl']" />
	
	<h:Button text="'Button 1'" classes="['redBtn']" />
	<h:Box layout="Horizontal">
		<h:Button text="'Button 2'" />
		
		<h:Box layout="Vertical">
			<h:Button text="'Button 3'" />
			<h:Button text="'Button 4'" />
		</h:Box>
	</h:Box>
	
	<view:CheckboxView />
	<view:CheckboxView />
	
	<h:Label text="'foo'" />
	<h:Label text="'bar'" />
	
	<h:Checkbox />
	
</h:Box>
```

Result: https://dl.dropboxusercontent.com/u/1036911/HXJointForces/index.html

Pseudo-code generation result: https://gist.github.com/bsideup/5966687

Roadmap
====
- Milestone 1
  - Reproduce Apache Flex MXML specification in Haxe
  - Test cases
  - Initial stable release
- Milestone 2
  - Specification major improvements 
  - Optimization
- Milestone 3
  - Better extensions support

How to contibute
====
We are opened for pull requests and contributions. Just stay hear http://sourceforge.net/adobe/flexsdk/wiki/MXML%202009/ specification:)
