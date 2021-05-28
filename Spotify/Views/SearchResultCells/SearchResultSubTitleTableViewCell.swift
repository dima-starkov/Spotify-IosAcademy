//
//  SearchResultSubTitleTableViewCell.swift
//  Spotify
//
//  Created by Дмитрий Старков on 02.05.2021.
//


import UIKit
import SDWebImage



class SearchResultSubTitleTableViewCell: UITableViewCell {
    static let identifier = "SearchResultSubTitleTableViewCell"
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()
   
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        //imageView.image = UIImage(systemName: "Contact")
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(label)
        addSubview(iconImageView)
        addSubview(subTitleLabel)
        clipsToBounds = true
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize: CGFloat = contentView.height - 10
        iconImageView.frame = CGRect(
            x: 10,
            y: 5,
            width: imageSize,
            height: imageSize)
        let labelHeight = contentView.height/2
        label.frame = CGRect(x: iconImageView.right + 10, y: 0, width: contentView.widht - iconImageView.right-15, height: labelHeight)
        subTitleLabel.frame = CGRect(x: iconImageView.right + 10, y: label.bottom, width: contentView.widht - iconImageView.right-15, height: labelHeight)
        
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        label.text = nil
        subTitleLabel.text = nil
    }
    
    func configure(with viewModel: SearchResultSubTitleTableViewCellViewModel) {
        label.text = viewModel.title
        subTitleLabel.text = viewModel.subtitle
        iconImageView.sd_setImage(with: viewModel.imageURL,placeholderImage: UIImage(systemName: "play"), completed: nil)
    }
}
