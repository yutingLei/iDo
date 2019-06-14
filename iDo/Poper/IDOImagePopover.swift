//
//  IDOImagePopover.swift
//  An image popover suitable local/remote
//
//  Created by admin on 2019/6/14.
//  Copyright © 2019 Conjur. All rights reserved.
//

import UIKit

public extension IDOImagePopover {
    enum BasePath {
        /// Document path
        case document
        /// Library path
        case library
        /// Cache path, /Library/Caches
        case cache
        /// None
        case none
    }
}

public class IDOImagePopover: IDOPopover {

    /// A image, set it will ignore localPath/remotePath
    public var image: UIImage?

    /// A base path for local. (default is .none)
    public var basePath: BasePath = .none

    /// A local path, set it will ignore image/remotePath
    public var localPath: String?

    /// A remote path, set it will ignore image/localPath
    public var remotePath: String?

    /// Is loading before loaded remote image,
    /// it's effectively when setted remotePath
    public var isLoading = true

    /// Show download button. (default true)
    public var showDownloadButton = true { willSet { downloadButton.isHidden = !newValue } }

    /// The imageView
    var imageView = UIImageView()

    /// The download button
    var downloadButton = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))

    /// Init
    public init(referenceView: UIView) {
        super.init()
        self.referenceView = referenceView
        contentView.addSubview(imageView)
        contentView.addSubview(downloadButton)

        imageView.contentMode = .scaleAspectFill

        downloadButton.setImage(IDOSource.getIcon(.download), for: .normal)
        downloadButton.addTarget(self, action: #selector(onDownload), for: .touchUpInside)
        downloadButton.imageView?.contentMode = .scaleAspectFit
        downloadButton.backgroundColor = UIColor.rgb(235, 235, 235)
        downloadButton.layer.masksToBounds = true
        downloadButton.layer.cornerRadius = 3
        downloadButton.isHidden = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public extension IDOImagePopover {
    /// Show
    override func show() {
        do {
            containerViewRect(with: try estimationImageSize())
            layoutSubviewOfContentView(with: imageView)
            layoutDownloadButton()
            super.show()
        } catch {
            print(error.localizedDescription)
        }
    }
}

//MARK: - Calculated
extension IDOImagePopover {

    /// Calculate image's size
    func estimationImageSize() throws -> CGSize {
        /// Fixed size
        if let fixedSize = fixedContentSize {
            if fixedSize.width <= 0 || fixedSize.height <= 0 {
                throw error(with: -1002, message: "It's unavailable to set width/height with '0' while using 'IDOImagePopover'.")
            }

            switch referenceLocation {
            case .left, .right: return fixedSize.add(dw: -16 - arrowHeight, dh: -16)
            default: return fixedSize.add(dw: -16, dh: -16 - arrowHeight)
            }
        }

        /// If image
        if let image = image {
            downloadButton.isHidden = !showDownloadButton
            return image.size
        }

        /// If local image
        if let localPath = localPath {
            do {
                downloadButton.isHidden = !showDownloadButton
                return try loadLocalImage(with: localPath)
            } catch {
                throw error
            }
        }

        /// If remote image
        if let remotePath = remotePath {
            do {
                return try loadRemoteImage(with: remotePath)
            } catch {
                throw error
            }
        }

        /// Default
        throw error(with: -1000, message: "Maybe you should sets a correct value of 'image'/'localPath'/'remotePath'")
    }

    /// Layout cancelButton
    func layoutDownloadButton() {
        downloadButton.frame.origin = CGPoint(x: contentView.frame.width - 33, y: isContainerViewLocatedAtTop ? 10 : 18)
    }
}

extension IDOImagePopover {

    /// Get base path
    func getBasePath() -> String? {
        switch basePath {
        case .document:
            return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        case .library:
            return NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first
        case .cache:
            return NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
        default:
            return nil
        }
    }

    /// Load local image
    func loadLocalImage(with path: String) throws -> CGSize {
        var absolutePath = path
        /// Appending path
        if let basePath = getBasePath() {
            absolutePath = (basePath as NSString).appendingPathComponent(path)
        }

        /// File exist?
        if FileManager.default.fileExists(atPath: absolutePath) {
            do {
                let data = try Data(contentsOf: URL(string: absolutePath)!)
                imageView.image = UIImage(data: data)
                return image?.size ?? CGSize.zero
            } catch {
                throw error
            }
        } else {
            throw error(with: -1001, message: "The file doesn't exist.")
        }
    }

    /// Load remote image
    func loadRemoteImage(with path: String) throws -> CGSize {
        /// Before loading, can add loading animations?
        if isLoading {
            imageView.addSubview({
                let activity = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 120, height: 120))
                activity.style = .gray
                activity.startAnimating()
                return activity
            }())
        }

        if imageView.image != nil {
            return imageView.image!.size
        }

        /// Init path
        if let remoteURL = URL(string: path) {
            DispatchQueue.global().async {[weak self] in
                do {
                    let data = try Data(contentsOf: remoteURL)
                    DispatchQueue.main.async {[weak self] in
                        if let image = UIImage(data: data) {
                            self?.downloadButton.isHidden = !(self?.showDownloadButton ?? true)
                            self?.imageView.image = image
                            self?.show()
                        }
                        _ = self?.imageView.subviews.map({ $0.removeFromSuperview() })
                    }
                } catch {
                    print("IDOImagePopover Error: \(error.localizedDescription)")
                }
            }
            return CGSize(width: 120, height: 120)
        }

        throw error(with: -1003, message: "Unavailable remote path.")
    }

    /// Download image/ save to library
    @objc func onDownload() {
        if let image = imageView.image {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        } else {
            print("Error: None image will be saved!")
        }
    }

    /// On download completion handler
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("Save Image Error: \(error.localizedDescription)")
        } else {
            Toast.show("保存成功")
        }
    }
}
