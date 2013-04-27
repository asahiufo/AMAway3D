package org.ahiufomasao.away3d.timeline 
{
	import away3d.animators.nodes.AnimationClipNodeBase;
	import away3d.animators.SkeletonAnimator;
	import org.ahiufomasao.yasume.events.TimelineEvent;
	import org.ahiufomasao.yasume.timeline.MainTimeline;
	
	/**
	 * アニメーターコネクター
	 * 
	 * @author asahiufo/AM902
	 */
	public class AnimatorConnector 
	{
		private var _mainTimeline:MainTimeline;
		private var _animator:SkeletonAnimator;
		
		/**
		 * コンストラクタ
		 * 
		 * @param mainTimeline メインタイムライン
		 * @param animator
		 */
		public function AnimatorConnector(mainTimeline:MainTimeline, animator:SkeletonAnimator) 
		{
			_mainTimeline = mainTimeline;
			_animator     = animator;
		}
		
		/**
		 * 初期処理.
		 * <p>
		 * SkeletonAnimatorが以下に設定されます。
		 * playbackSpeed = 1
		 * autoUpdate = false
		 * </p>
		 */
		public function initialize():void
		{
			_animator.playbackSpeed = 1;
			_animator.autoUpdate = false;
			_mainTimeline.addEventListener(TimelineEvent.CHANGE_FRAME_AFTER, _onChangeFrameAfter);
			_mainTimeline.addEventListener(TimelineEvent.ANIMATE_AFTER, _onAnimateAfter);
		}
		/**
		 * 終了処理
		 */
		public function terminate():void
		{
			_mainTimeline.removeEventListener(TimelineEvent.ANIMATE_AFTER, _onAnimateAfter);
			_mainTimeline.removeEventListener(TimelineEvent.CHANGE_FRAME_AFTER, _onChangeFrameAfter);
		}
		
		/**
		 * @private
		 * フレーム変更イベントハンドラ
		 * 
		 * @param event イベント
		 */
		private function _onChangeFrameAfter(event:TimelineEvent):void
		{
			_animator.play(_mainTimeline.currentChildTimeline.graphicsFrameName);
		}
		
		/**
		 * @private
		 * アニメーションイベントハンドラ
		 * 
		 * @param event イベント
		 */
		private function _onAnimateAfter(event:TimelineEvent):void
		{
			if (!(_animator.activeAnimation is AnimationClipNodeBase))
			{
				return;
			}
			
			var animationClipNode:AnimationClipNodeBase = _animator.activeAnimation as AnimationClipNodeBase;
			
			// Away3D 側のアニメーションのトータルミリ秒
			var totalDuration:uint = 0;
			// ループする場合はすべてのアニメーションのトータルミリ秒を採用
			if (_mainTimeline.currentChildTimeline.repeat)
			{
				totalDuration = animationClipNode.totalDuration;
			}
			// ループしない場合は末尾フレームのミリ秒は捨ててトータルミリ秒を計算
			else
			{
				var durations:Vector.<uint> = animationClipNode.durations;
				var length:uint = durations.length;
				for (var i:uint = 0; i < length - 2; i++)
				{
					totalDuration += durations[i];
				}
			}
			
			// タイムラインの全フレーム数
			var frameLength:uint = _mainTimeline.currentChildTimeline.length;
			
			// 1 フレーム辺りのミリ秒
			var oneFrameMS:Number = totalDuration / frameLength;
			
			// Away3D 側の表示更新
			_animator.update((_mainTimeline.currentChildTimeline.currentFrame - 1) * oneFrameMS);
		}
	}
}