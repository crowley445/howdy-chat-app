
import UIKit

class AddContactsViewController: UIViewController {
    
    @IBOutlet weak var usersTableView: UITableView!
    @IBOutlet weak var searchBar : UISearchBar!
    
    var usersArray = [User]()
    var filteredUserArray = [User]()
    var selectedUsers = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usersTableView.delegate = self
        usersTableView.dataSource = self
        searchBar.delegate = self
        searchBar.returnKeyType = .done
        searchBar.isHidden = true
        getAllUsersForDisplay()
    }
    
    private func getAllUsersForDisplay () {
        DatabaseService.instance.getUsers { (users) in
            self.usersArray = users
            self.searchBar.isHidden = false
            self.filterUsersAndReloadTableView()
        }
    }
    
    private func filterUsersAndReloadTableView () {
        if let query = searchBar.text, searchBar.text != "" {
            filteredUserArray = usersArray.filter{$0.name.contains(query)}
        } else{
            filteredUserArray = usersArray
        }
        usersTableView.reloadData()
    }
    
    @IBAction func backButtonPressed( _ sender: Any) {
        print("AddContactsViewController: Back button pressed.")
    }
    
    @IBAction func nextButtonPressed( _ sender: Any) {
        print("AddContactsViewController: Next button pressed.")
    }
}

extension AddContactsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUserArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CONTACT_CELL_ID, for: indexPath) as? ContactCell else {
            return UITableViewCell()
        }
        cell.configure(withUser: filteredUserArray[indexPath.row], setSelected: !selectedUsers.contains(where: {$0.uid == filteredUserArray[indexPath.row].uid}))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ContactCell else { return }
        cell.toggleCheckmark()

        if let i = selectedUsers.index(where: {$0.uid == cell.user.uid}) {
            selectedUsers.remove(at: i)
        } else {
            selectedUsers.append(cell.user)
        }
    }
    
}

extension AddContactsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterUsersAndReloadTableView()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
}
