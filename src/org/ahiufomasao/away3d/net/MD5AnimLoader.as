package org.ahiufomasao.away3d.net 
{
	import away3d.animators.data.Skeleton;
	import away3d.animators.nodes.SkeletonClipNode;
	import away3d.animators.SkeletonAnimationSet;
	import away3d.animators.SkeletonAnimator;
	import away3d.entities.Mesh;
	import away3d.events.AssetEvent;
	import away3d.events.LoaderEvent;
	import away3d.library.assets.AssetType;
	import away3d.loaders.Loader3D;
	import away3d.loaders.parsers.MD5AnimParser;
	import away3d.loaders.parsers.MD5MeshParser;
	import away3d.loaders.parsers.ParserBase;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import org.ahiufomasao.utility.net.ILoader;
	
	// TODO: asdoc
	// TODO: テスト
	/**
	 * <code>MD5AnimLoader</code> クラスは、Away3D で MD5 形式のデータのロードまたはパース機能を提供します.
	 * 
	 * @author asahiufo/AM902
	 */
	public class MD5AnimLoader extends EventDispatcher implements ILoader
	{
		private var _source:Object;
		
		private var _skeletonClipNode:SkeletonClipNode;
		
		private var _loader:Loader3D;
		private var _complete:Boolean; // ロードが完了しているならtrue
		
		/**
		 * 常に 0 です。
		 */
		public function get bytesLoaded():uint { return 0; }
		/**
		 * 常に 0 です。
		 */
		public function get bytesTotal():uint { return 0; }
		/**
		 * @inheritDoc
		 */
		public function get loading():Boolean
		{
			if (complete)
			{
				return false;
			}
			else if (_loader == null)
			{
				return false;
			}
			return true;
		}
		/**
		 * @inheritDoc
		 */
		public function get complete():Boolean { return _complete; }
		/**
		 * 読み込まれた Asset データ（<code>SkeletonClipNode</code> オブジェクト）です.
		 * <p>
		 * ロードが完了するまでは <code>null</code> です。
		 * </p>
		 */
		public function get data():Object
		{
			return _skeletonClipNode;
		}
		
		/**
		 * 新しい <code>MD5AnimLoader</code> クラスのインスタンスを生成します.
		 * 
		 * @param source パース対象オブジェクト
		 */
		public function MD5AnimLoader(source:Object)
		{
			_source   = source;
			
			_skeletonClipNode = null;
		
			_loader   = null;
			_complete = false;
		}
		
		/**
		 * @inheritDoc
		 * 
		 * @throws IllegalOperationError <code>load</code> メソッドを 2 回以上実行した場合にスローされます。
		 */
		public function load():void
		{
			if (_loader != null)
			{
				throw new IllegalOperationError("ロードは実施済みです。");
			}
			
			_loader = new Loader3D();
			_loader.addEventListener(AssetEvent.ASSET_COMPLETE, _onAssetComplete);
			_loader.addEventListener(LoaderEvent.RESOURCE_COMPLETE, _onResourceComplete);
			_loader.addEventListener(LoaderEvent.LOAD_ERROR, _onLoadError);
			_loader.loadData(_source, null, null, new MD5AnimParser());
		}
		
		/**
		 * @private
		 * アセットコンプリートイベントハンドラ
		 * 
		 * @param event イベント
		 */
		private function _onAssetComplete(event:AssetEvent):void
		{
			if (event.asset.assetType == AssetType.ANIMATION_NODE)
			{
				_skeletonClipNode = event.asset as SkeletonClipNode;
			}
		}
		
		/**
		 * @private
		 * リソースコンプリートイベントハンドラ
		 * 
		 * @param event イベント
		 */
		private function _onResourceComplete(event:LoaderEvent):void
		{
			_loader.removeEventListener(LoaderEvent.LOAD_ERROR, _onLoadError);
			_loader.removeEventListener(LoaderEvent.RESOURCE_COMPLETE, _onResourceComplete);
			_loader.removeEventListener(AssetEvent.ASSET_COMPLETE, _onAssetComplete);
			
			_complete = true;
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/**
		 * @private
		 * ロードエラーイベントハンドラ
		 * 
		 * @param event イベント
		 */
		private function _onLoadError(event:LoaderEvent):void
		{
			throw new SecurityError("ロードエラーが発生しました。[" + event.toString() + "]");
		}
		
		/**
		 * 読み込んだデータの複製を取得します.
		 * 
		 * @return 読み込んだデータの複製
		 * 
		 * @throws IllegalOperationError ロード未完了の状態で実行した場合にスローされます。
		 */
		public function cloneData():Object
		{
			if (!complete)
			{
				throw new IllegalOperationError("ロードが完了していません。");
			}
			
			// TODO: AssetLibrary.getAsset()でやんの？
			return data;
		}
		
		/**
		 * <code>MD5AnimLoader</code> オブジェクトのプロパティを含むストリングを返します.
		 * <p>
		 * ストリングは次の形式です。
		 * </p>
		 * <p>
		 * <code>[MD5AnimLoader  complete=<em>value</em> data="<em>value</em>"]</code>
		 * </p>
		 * 
		 * @return <code>MD5AnimLoader</code> オブジェクトのプロパティを含むストリングです。
		 */
		override public function toString():String 
		{
			return ("[MD5AnimLoader complete=" + _complete + " data=\"" + data + "\"]");
		}
	}
}
