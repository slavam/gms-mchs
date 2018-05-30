class CalcParams extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      postId: this.props.postId,
      dateFrom: this.props.dateFrom,
      dateTo: this.props.dateTo
    };
    this.handleOptionSelected = this.handleOptionSelected.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
    this.dateFromChange = this.dateFromChange.bind(this);
    this.dateToChange = this.dateToChange.bind(this);
  }
  handleSubmit(e) {
    e.preventDefault();
    // alert('handleSubmit')
    var postId = this.state.postId;
    var dateFrom = this.state.dateFrom;
    var dateTo = this.state.dateTo;
    if (!dateFrom || !dateTo || !postId) {
      return;
    }
    this.props.onParamsSubmit({dateFrom: dateFrom, dateTo: dateTo, postId: postId});
  }
  handleOptionSelected(value, senderName){
    if (senderName == 'selectPost'){
      this.state.postId = value;
    }
  }
  dateFromChange(e) {
    this.setState({dateFrom: e.target.value});
  }
  dateToChange(e) {
    this.setState({dateTo: e.target.value});
  }
  render() {
    // var defaultId = this.props.regionType == 'post' ? 5 : 1;
    return (
      <form className="paramsForm" onSubmit={this.handleSubmit}>
        <table className= "table table-hover">
          <thead>
            <tr>
              <th>Пост</th>
              <th>Начальная дата</th>
              <th>Конечная дата</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>
                <ChemOptionSelect options={this.props.posts} onUserInput={this.handleOptionSelected} name="selectPost" key="selectPost" defaultValue = {this.state.postId}/>
              </td>
              <td>
                <input type="date" name="dateFrom" value={this.state.dateFrom} onChange={this.dateFromChange} />
              </td>
              <td>
                <input type="date" name="dateTo" value={this.state.dateTo} onChange={this.dateToChange} />
              </td>
            </tr>
          </tbody>
        </table>
        <input type="submit" value="Пересчитать" />
      </form>
    );
  }
}

class VolumeNormal extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      dateFrom: this.props.dateFrom,
      dateTo: this.props.dateTo,
      post: this.props.post,
      numberMeasurements: this.props.numberMeasurements,
      volumeTotal: this.props.volumeTotal,
      volumeSampleDust: this.props.volumeSampleDust
    };
    // this.desiredLink = "/measurements/print_forma2.pdf?date_from="+this.props.dateFrom+"&date_to="+this.props.dateTo+"&place_id="+this.props.placeId+"&region_type="+this.props.regionType;
    this.volumeParamsSubmit = this.volumeParamsSubmit.bind(this);
  }
  
  volumeParamsSubmit(params) {
    // alert('volumeParamsSubmit')
    // this.desiredLink = "/measurements/print_forma2.pdf?date_from="+params.dateFrom+"&date_to="+params.dateTo+"&place_id="+params.placeId+"&region_type="+this.props.regionType;
    $.ajax({
      type: 'GET',
      dataType: 'json',
      url: "calc_normal_volume?date_from="+params.dateFrom+"&date_to="+params.dateTo+"&post_id="+params.postId
      }).done(function(data) {
        // alert(data.dateFrom)
        this.setState({
          post: data.post,
          volumeTotal: data.volumeTotal,
          volumeSampleDust: data.volumeSampleDust,
          numberMeasurements: data.numberMeasurements,
          dateFrom: data.dateFrom,
          dateTo: data.dateTo
        });
      }.bind(this))
      .fail(function(jqXhr) {
        console.log('failed to register');
      });
  }
  render(){
    return(
      <div>
        <h3>Задайте параметры расчета</h3>
        <CalcParams onParamsSubmit={this.volumeParamsSubmit} dateFrom={this.state.dateFrom} dateTo={this.state.dateTo} postId={this.state.post.id} posts={this.props.posts}/>
        <br />
        <h4>{this.state.post.name}</h4>
        <h4>Период с {this.state.dateFrom} по {this.state.dateTo}</h4>
        <h4>Объем отобраной пробы пыли {this.state.volumeSampleDust} дм.<sup>3</sup> </h4>
        <h4>Количество измерений {this.state.numberMeasurements}</h4>
        <h4>Объем пробы, приведенный к нормальным условиям за период {this.state.volumeTotal} дм.<sup>3</sup></h4>
      </div>
    );
  }
}