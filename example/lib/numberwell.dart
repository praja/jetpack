import 'package:flutter/material.dart';

class NumberWell extends StatelessWidget { 
	final VoidCallback? onTap;
	final int count;

	const NumberWell(this.count,{super.key, this.onTap}); 

	@override Widget build(BuildContext context) {
		return InkWell(
			onTap: onTap,
			child: Container(
				width: double.infinity,
				alignment: Alignment.center,
				child: Padding(
					padding: const EdgeInsets.symmetric(vertical: 24),
					child: Text(
						'$count',
						style: Theme.of(context).textTheme.headlineSmall,
					),
				),
			)
		);
	}
}
