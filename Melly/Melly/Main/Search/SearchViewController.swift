//
//  SearchViewController.swift
//  Melly
//
//  Created by Jun on 2022/10/05.
//

import UIKit
import RxCocoa
import RxSwift

protocol GoPlaceDelegate:AnyObject {
    func showLocationPopupView(_ place: Place)
    func goToAddMemoryView(_ place: Place)
    func goToMemoryView(_ memory: Memory)
}

class SearchViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let vm:SearchViewModel
    
    weak var delegate:GoPlaceDelegate?
    
    var isSearch:Bool = false {
        didSet {
            if isSearch {
                recentView.isHidden = true
                searchView.isHidden = false
            } else {
                recentView.isHidden = false
                searchView.isHidden = true
            }
        }
    }
    
    let searchTextField = SearchTextField()
    
    let recentView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    let recentLB = UILabel().then {
        $0.text = "최근검색"
        $0.textColor = UIColor(red: 0.42, green: 0.463, blue: 0.518, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Bold", size: 18)
    }
    
    let separator = UIView().then {
        $0.backgroundColor = UIColor(red: 0.945, green: 0.953, blue: 0.961, alpha: 1)
    }
    
    lazy var recentCV: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    let searchView = UIView().then {
        $0.backgroundColor = .clear
        $0.isHidden = true
    }
    
    let searchCV: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    init(vm: SearchViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        bind()
        setCV()
    }
    
}

extension SearchViewController {
    
    func setUI() {
        self.view.backgroundColor = UIColor(red: 0.961, green: 0.961, blue: 0.961, alpha: 1)
        
        safeArea.addSubview(searchTextField)
        searchTextField.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(44)
        }
        
        safeArea.addSubview(recentView)
        recentView.snp.makeConstraints {
            $0.top.equalTo(searchTextField.snp.bottom).offset(26)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        safeArea.addSubview(searchView)
        searchView.snp.makeConstraints {
            $0.top.equalTo(searchTextField.snp.bottom).offset(26)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        searchView.addSubview(searchCV)
        searchCV.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
        }
        
        recentView.addSubview(recentLB)
        recentLB.snp.makeConstraints {
            $0.top.equalToSuperview().offset(26)
            $0.leading.equalToSuperview().offset(30)
        }
        
        recentView.addSubview(separator)
        separator.snp.makeConstraints {
            $0.top.equalTo(recentLB.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(2)
        }
        
        recentView.addSubview(recentCV)
        recentCV.snp.makeConstraints {
            $0.top.equalTo(separator.snp.bottom)
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
        }
        
        
        
    }
    
    func setCV() {
        recentCV.dataSource = nil
        recentCV.delegate = nil
        recentCV.rx.setDelegate(self).disposed(by: disposeBag)
        recentCV.register(SearchCell.self, forCellWithReuseIdentifier: "recent")
        
        recentCV.rx.itemSelected
            .map { index in
                let cell = self.recentCV.cellForItem(at: index) as! SearchCell
                return cell.search!
            }
            .bind(to: vm.input.clickSearchObserver)
            .disposed(by: disposeBag)
        
        vm.output.recentValue
            .bind(to: recentCV.rx.items(cellIdentifier: "recent", cellType: SearchCell.self)) { row, element, cell in
                cell.setData(element, self.vm)
            }.disposed(by: disposeBag)
    
        searchCV.dataSource = nil
        searchCV.delegate = nil
        searchCV.rx.setDelegate(self).disposed(by: disposeBag)
        searchCV.register(SearchCell.self, forCellWithReuseIdentifier: "search")
        
        searchCV.rx.itemSelected
            .map { index in
                let cell = self.searchCV.cellForItem(at: index) as! SearchCell
                return cell.search!
            }
            .bind(to: vm.input.clickSearchObserver)
            .disposed(by: disposeBag)
        
        vm.output.searchValue
            .bind(to: searchCV.rx.items(cellIdentifier: "search", cellType: SearchCell.self)) { row, element, cell in
                cell.setData(element, self.vm)
            }.disposed(by: disposeBag)
        
        
    }
    
    func bind() {
        bindInput()
        bindOutput()
    }
    
    func bindInput() {
        searchTextField.leftBt.rx.tap
            .subscribe(onNext: {
                self.dismiss(animated: true)
            }).disposed(by: disposeBag)
        
        searchTextField.rx.text.orEmpty
            .debounce(RxTimeInterval.microseconds(5), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(to: vm.input.searchObserver)
            .disposed(by: disposeBag)
        
        searchTextField.rx.text
            .debounce(RxTimeInterval.microseconds(5), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(to: vm.input.searchTextObserver)
            .disposed(by: disposeBag)
            
        
        searchTextField.rightBt.rx.tap
            .subscribe(onNext: {
                self.searchTextField.text = ""
                self.isSearch = false
            }).disposed(by: disposeBag)
        
        
    }
    
    func bindOutput() {
        vm.output.switchValue.asDriver(onErrorJustReturn: false)
            .drive(onNext: { value in
                self.isSearch = value
            }).disposed(by: disposeBag)
        
        vm.output.getPlaceValue.subscribe(onNext: { value in
            
            self.delegate?.showLocationPopupView(value)
            self.dismiss(animated: true)
            
        }).disposed(by: disposeBag)
        
        vm.output.goToMemoryValue.subscribe(onNext: { value in
            self.delegate?.goToAddMemoryView(value)
            self.dismiss(animated: true)
        }).disposed(by: disposeBag)
        
        
        vm.output.tfRightViewValue.asDriver(onErrorJustReturn: false)
            .drive(onNext: { value in
                if value {
                    self.searchTextField.rightViewMode = .always
                } else {
                    self.searchTextField.rightViewMode = .never
                }
                
            }).disposed(by: disposeBag)
        
    }
    
}

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width - 60
        return CGSize(width: width, height: 56)
    }
}


class SearchCell: UICollectionViewCell {
    private let disposeBag = DisposeBag()
    var vm:SearchViewModel?
    var search:Search?
    
    let imageView = UIImageView()
    
    let locationLB = UILabel().then {
        $0.textColor = UIColor(red: 0.42, green: 0.463, blue: 0.518, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 16)
    }
    
    let removeButton = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "search_x"), for: .normal)
    }
    
    let separator = UIView().then {
        $0.backgroundColor = UIColor(red: 0.945, green: 0.953, blue: 0.961, alpha: 1)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        
    }
    
    private func setupView() {
        backgroundColor = .clear
        
        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview().offset(16)
        }
        
        addSubview(locationLB)
        locationLB.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15)
            $0.leading.equalTo(imageView.snp.trailing).offset(10)
        }
        
        addSubview(removeButton)
        removeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.top.equalToSuperview().offset(17)
            $0.leading.greaterThanOrEqualTo(locationLB.snp.trailing).offset(10)
        }
        
    }
    
    func setData(_ search: Search, _ vm: SearchViewModel) {
        
        locationLB.text = search.title
        imageView.image = UIImage(named: search.img)
        self.removeButton.isHidden = search.isRecent ? false : true
        self.search = search
        self.vm = vm
        bind()
    }
    
    
    func bind() {
        
        removeButton.rx.tap
            .map { self.search! }
            .bind(to: vm!.input.removeRecentObserver)
            .disposed(by: disposeBag)
        
    }
    
}



class SearchTextField: UITextField {
    
    //w:51, h:44
    let leftPaddingView = UIView()
    let leftBt = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "search_back"), for: .normal)
        $0.imageView?.contentMode = .scaleAspectFit
    }
    
    let rightPaddingView = UIView()
    let rightBt = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "search_x"), for: .normal)
        $0.imageView?.contentMode = .scaleAspectFit
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupViews() {
        self.font = UIFont(name: "Pretendard-Regular", size: 14)
        self.placeholder = "장소, 메모리 검색"
        self.textColor = UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1)
        
        
        leftPaddingView.snp.makeConstraints {
            $0.width.equalTo(51)
            $0.height.equalTo(44)
        }
        
        leftPaddingView.addSubview(leftBt)
        leftBt.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
        
        rightPaddingView.snp.makeConstraints {
            $0.width.equalTo(40)
            $0.height.equalTo(44)
        }
        
        rightPaddingView.addSubview(rightBt)
        rightBt.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        self.rightView = rightPaddingView
        self.rightViewMode = .never
        self.leftView = leftPaddingView
        self.leftViewMode = .always
        self.backgroundColor = .white
        self.layer.cornerRadius = 12
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(red: 0.945, green: 0.953, blue: 0.961, alpha: 1).cgColor
        
    }
    

}
