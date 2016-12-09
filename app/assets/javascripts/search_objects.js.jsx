class RegisterRow extends React.Component {
  render() {
    return (
      <tr>
        <td>{this.props.register["Наименнование"]}</td>
        <td>{this.props.register["Формуляр"]}</td>
        <td>{this.props.register["Инвентарный"]}</td>
        <td>{this.props.register["Кабинет"]}</td>
        <td>{this.props.register["Ответственный"]}</td>
      </tr>
    );
  }
}
class ObjectTable extends React.Component {
  render() {
    var rows = [];
    var searchName = this.props.filterName;
    var searchRoom = this.props.filterRoom;
    this.props.registers.forEach(function(register) {
      if (register["Наименнование"].indexOf(searchName) === -1 || register["Кабинет"].indexOf(searchRoom) === -1) {
        return;
      }
      rows.push(<RegisterRow register={register} key={register.id} />);
    });
    return (
      <table>
        <thead>
          <tr>
            <th>Наименнование</th>
            <th>Формуляр</th>
            <th>Инвентарный</th>
            <th>Кабинет</th>
            <th>Ответственный</th>
          </tr>
        </thead>
        <tbody>{rows}</tbody>
      </table>
    );
  }
}
class SearchBar extends React.Component {
  constructor(props) {
    super(props);
    this.handleChange = this.handleChange.bind(this);
  }
  
  handleChange() {
    this.props.onUserInput(
      this.filterNameInput.value,
      this.filterRoomInput.value
    );
  }
  render() {
    return (
      <form>
        <input type="text" placeholder="Название..." value={this.props.filterName} ref={(input) => this.filterNameInput = input} onChange={this.handleChange}/>
        <input type="text" placeholder="Кабинет..." value={this.props.filterRoom} ref={(input) => this.filterRoomInput = input} onChange={this.handleChange}/>
      </form>
    );
  }
}
class SearchObjects extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      filterName: '',
      filterRoom: ''
    };
    this.handleUserInput = this.handleUserInput.bind(this);
  }

  handleUserInput(filterName, filterRoom) {
    this.setState({
      filterName: filterName,
      filterRoom: filterRoom
    });
  }
  render(){
    return(
      <div>
        <SearchBar filterName={this.state.filterName} filterRoom={this.state.filterRoom} onUserInput={this.handleUserInput} />
        <ObjectTable registers={this.props.registers} filterName={this.state.filterName} filterRoom={this.state.filterRoom} />
      </div>
    );
  }
}