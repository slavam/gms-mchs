class FoundTelegram extends React.Component{
  constructor(props) {
    super(props);
    // this.state = {
    //   tlgText: this.props.telegram.telegram,
    //   tlgId: this.props.telegram.id,
    //   mode: 'Изменить'
    // };
    // this.handleEditClick = this.handleEditClick.bind(this);
    // this.handleEditTelegramSubmit = this.handleEditTelegramSubmit.bind(this);
  }
  render() {
    var desiredLink = "/synoptic_observations/"+this.props.telegram.id;
    return (
      <tr>
        <td>{this.props.telegram.date}</td>
        <td>{this.props.telegram.term}</td>
        <td>{this.props.telegram.station_name}</td>
        <td><a href={desiredLink}>{this.props.telegram.telegram}</a></td>
      </tr>
    );
  }
}

class FoundTelegrams extends React.Component{
  render() {
    var rows = [];
    // var that = this;
    this.props.telegrams.forEach(function(t) {
      rows.push(<FoundTelegram telegram={t} key={t.id}/>);
    });
    return (
      <table className="table table-hover">
        <thead>
          <tr>
            <th>Дата</th>
            <th>Срок</th>
            <th>Метеостанция</th>
            <th>Текст</th>
          </tr>
        </thead>
        <tbody>{rows}</tbody>
      </table>
    );
  }
}

class SearchSynopticTelegrams extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
    //   date: this.props.date,
      telegrams: this.props.telegrams,
      errors: {}
    };
    this.handleFormSubmit = this.handleFormSubmit.bind(this);
  }

  handleFormSubmit(telegram) {
    var that = this;
    $.ajax({
      type: 'POST',
      dataType: 'json',
      data: {observation: telegram.observation},
      url: "create_synoptic_telegram?station_code="+telegram.stationIndex
      }).done(function(data) {
        that.setState({telegrams: data.telegrams, errors: {}});
      }.bind(that))
      .fail(function(res) {
        that.setState({errors: ["Ошибка записи в базу"]});
      }.bind(that)); 
  }
  
  render(){
    return(
      <div>
        <h3>Параметры поиска</h3>
        {/*<SearchParamsForm onTelegramSubmit={this.handleFormSubmit} tlgHeader='ЩЭСМЮ' errors={this.state.errors} stations={this.props.stations} tlgText={this.state.tlgText}/> */}
        <h3>Телеграммы</h3>
        <FoundTelegrams telegrams={this.state.telegrams}/>
      </div>
    );
  }
}